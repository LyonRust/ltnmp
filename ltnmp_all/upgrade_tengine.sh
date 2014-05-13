#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "Upgrade Nginx for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com"
echo "========================================================================="

nv=`/usr/local/nginx/sbin/nginx -v 2>&1`
old_tengine_version=`echo $nv | cut -c22-`
#echo $old_tengine_version

if [ "$1" != "--help" ]; then

#set tengine version

	tengine_version=""
	echo "Current Nginx Version:$old_tengine_version"
	echo "Please input Tengine version you want:"
	echo "You can get version number from http://tengine.taobao.org/download.html"
	read -p "(example: 1.3.0 ):" tengine_version
	if [ "$tengine_version" = "" ]; then
		echo "Error: You must input Tengine version!!"
		exit 1
	fi
	echo "==========================="

	echo "You want to upgrade Tengine version to $tengine_version"

	echo "==========================="

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
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "============================check files=================================="
if [ -s nginx-$tengine_version.tar.gz ]; then
  echo "Tengine-$tengine_version.tar.gz [found]"
  else
  echo "Error: Tengine-$tengine_version.tar.gz not found!!!download now......"
  wget -c http://tengine.taobao.org/download/tengine-$tengine_version.tar.gz
  dl_status=`echo $?`
  if [ $dl_status = "0" ]; then
	echo "Download Tengine-$tengine_version.tar.gz successfully!"
  else
	echo "WARNING!May be the Tengine version you input was wrong,please check!"
	echo "tengine Version input was:"$tengine_version
	sleep 5
	exit 1
  fi
fi
echo "============================check files=================================="
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi
rm -rf tengine-$tengine_version/
tar zxvf tengine-$tengine_version.tar.gz
cd tengine-$tengine_version/
/usr/local/nginx/sbin/nginx -V &> $$
tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
rm -rf $$
./configure $tengine_configure_arguments
make && make install

mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old
cp objs/nginx /usr/local/nginx/sbin/nginx
/usr/local/nginx/sbin/nginx -t
make upgrade
echo "Upgrade completed!"
echo "Program will display Nginx Version......"
/usr/local/nginx/sbin/nginx -v
cd ../

echo "Restarting Nginx..."
/etc/init.d/nginx restart

echo "Starting MySQL..."
/etc/init.d/mysql start
echo "Starting PHP-FPM..."
/etc/init.d/php-fpm start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi

echo "========================================================================="
echo "You have successfully upgrade from $old_tengine_version to $tengine_version"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com"
echo ""
echo "========================================================================="
fi
