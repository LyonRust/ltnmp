#!/bin/bash

clear
echo "========================================================================="
echo "Google Perf Tools Installation for LTNMP Written by php360"
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
echo ""
cur_dir=$(pwd)

#set gperftools version

	echo "You can get version number from http://code.google.com/p/gperftools/"
	read -p "Please input gperftools version you want(example: 2.0.99 ):" version
	if [ "$version" = "" ]; then
	echo "Error: You must input gperftools $version!!"
	exit 1
	fi
	echo "=================================================="
	echo "You want to upgrade gperftools to gperftools-$version"
	echo "=================================================="
	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start installation or CTRL+C to cancel."
	char=`get_char`
echo "========================================================================="
echo "Installing..."
echo "========================================================================="

bit=$(getconf LONG_BIT)
if [ "$bit" = "64" ]; then
rm -rf zxvf libunwind-1.1.tar.gz
rm -rf zxvf libunwind-1.1
wget http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/libunwind-1.1.tar.gz
tar zxvf libunwind-1.1.tar.gz
cd libunwind-1.1
CFLAGS=-fPIC ./configure
make CFLAGS=-fPIC
make CFLAGS=-fPIC install
make && make install
cd ../
fi

wget http://gperftools.googlecode.com/files/gperftools-$version.tar.gz
tar zxvf gperftools-$version.tar.gz
cd gperftools-$version
./configure --prefix=/usr/local --enable-shared --enable-frame-pointers
make && make install
cd ../

echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig

if [ -f /usr/local/nginx/conf/nginx.conf ];then
sed -i '/google_perftools_profiles/d' /usr/local/nginx/conf/nginx.conf
sed -i '/nginx.pid'/a\ "google_perftools_profiles \/tmp\/tcmalloc;" /usr/local/nginx/conf/nginx.conf
fi
if [ -f /usr/local/mysql/bin/mysqld_safe ];then
sed -i '/export LD_PRELOAD=/d' /usr/local/mysql/bin/mysqld_safe
sed -i '/executing mysqld_safe'/a\ "export LD_PRELOAD=\/usr\/local\/lib\/libtcmalloc.so" /usr/local/mysql/bin/mysqld_safe
fi
/etc/init.d/nginx restart
/etc/init.d/mysql restart
lsof -n | grep tcmalloc
echo "========================================================================="
echo "Install gperftools  completed,enjoy it!"
echo "========================================================================="
echo "Install gperftools for LTNMP  ,  Written by php360"
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux"
echo "For more information please visit http://www.05gzs.com"
echo "========================================================================="
