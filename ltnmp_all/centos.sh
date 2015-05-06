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
echo "LTNMP for CentOS/RadHat Linux VPS  Written by PHP360"
echo "========================================================================="
echo "A tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
cur_dir=$(pwd)

#set area

	area="asia"
	echo "Where are your servers located? asia,america,europe,oceania or africa "
	read -p "(Default area: asia):" area
	if [ "$area" = "" ]; then
		area="asia"
	fi
	echo "==========================="
	echo  "area=$area"
	echo "==========================="

#set mysql root password
	mysqlrootpwd="root"
	echo "Please input the root password of mysql:"
	read -p "(Default password: root):" mysqlrootpwd
	if [ "$mysqlrootpwd" = "" ]; then
		mysqlrootpwd="root"
	fi
	echo "==========================="
	echo "MySQL root password:$mysqlrootpwd"
	echo "==========================="

#do you want to install the InnoDB Storage Engine?
echo "==========================="

	installinnodb="y"
	echo "Do you want to install the InnoDB Storage Engine?"
	read -p "(Default y,if you dont want please input: n ,if you want please input: y or press the enter button):" installinnodb

	case "$installinnodb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install the InnoDB Storage Engine"
	installinnodb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will NOT install the InnoDB Storage Engine!"
	installinnodb="n"
	;;
	*)
	echo "INPUT error,The InnoDB Storage Engine will install!"
	installinnodb="y"
	esac

#which PHP Version do you want to install?
echo "==========================="

	isinstallphp="y"
	echo "Install PHP 5.4.24,Please input y or press Enter"
	echo "Install PHP 5.3.28,Please input n"
	read -p "(Please input y or n):" isinstallphp

	case "$isinstallphp" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install PHP 5.4.24"
	isinstallphp="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install PHP 5.3.28"
	isinstallphp="n"
	;;
	*)
	echo "INPUT error,You will install PHP 5.4.24"
	isinstallphp="y"
	esac

#which MySQL Version do you want to install?
echo "==========================="

	isinstallMariadb="y"
	echo "Install mariadb-5.5.33a,Please input y or press Enter"
	echo "Install MySQL 5.5.35,Please input n"
	read -p "(Please input y or n):" isinstallMariadb

	case "$isinstallMariadb" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install mariadb-5.5.33a"
	isinstallMariadb="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install MySQL 5.5.35"
	isinstallMariadb="n"
	;;
	*)
	echo "INPUT error,You will install mariadb-5.5.33a"
	isinstallMariadb="y"
	esac

#which Tengine Version do you want to install?
echo "==========================="

	isinstallTengine="y"
	echo "Install Tengine 2.0.0,Please input y or press Enter"
	echo "Install Nginx 1.5.9,Please input n"
	read -p "(Please input y or n):" isinstallTengine

	case "$isinstallTengine" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install Tengine 2.0.0"
	isinstallTengine="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install Nginx 1.5.9"
	isinstallTengine="n"
	;;
	*)
	echo "INPUT error,You will install Tengine 2.0.0"
	isinstallTengine="y"
	esac

#which TCMalloc Version do you want to install?
echo "==========================="

	isinstallTCMalloc="n"
	echo "Install gperftools 2.1,Please input y"
	echo "Install jemalloc 3.4.0,Please input n or press Enter"
	read -p "(Please input y or n):" isinstallTCMalloc

	case "$isinstallTCMalloc" in
	y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
	echo "You will install gperftools 2.1"
	isinstallTCMalloc="y"
	;;
	n|N|No|NO|no|nO)
	echo "You will install jemalloc 3.4.0"
	isinstallTCMalloc="n"
	;;
	*)
	echo "INPUT error,You will install jemalloc 3.4.0"
	isinstallTCMalloc="n"
	esac

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

function InitInstall()
{
	cat /etc/issue
	uname -a
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`
	echo -e "\n Memory is: ${MemTotal} MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	rpm -qa|grep httpd
	rpm -e httpd
	rpm -qa|grep mysql
	rpm -e mysql
	rpm -qa|grep php
	rpm -e php

	yum -y remove httpd*
	yum -y remove php*
	yum -y remove mysql-server mysql
	yum -y remove php-mysql

	yum -y install yum-fastestmirror
	yum -y remove httpd
	#yum -y update

	#Disable SeLinux
	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	cp /etc/yum.conf /etc/yum.conf.lnmp
	sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

	for packages in patch make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap;
	do yum -y install $packages; done

	mv -f /etc/yum.conf.lnmp /etc/yum.conf
}

function CheckAndDownloadFiles()
{
echo "============================check files=================================="
if [ "$isinstallphp" = "n" ]; then
	if [ -s php-5.3.28.tar.gz ]; then
	  echo "php-5.3.28.tar.gz [found]"
	  else
	  echo "Error: php-5.3.28.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/php-5.3.28.tar.gz
	fi
else
	if [ -s php-5.4.24.tar.gz ]; then
	  echo "php-5.4.24.tar.gz [found]"
	  else
	  echo "Error: php-5.4.24.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/php-5.4.24.tar.gz
	fi
fi

if [ -s pcre-8.12.tar.gz ]; then
  echo "pcre-8.12.tar.gz [found]"
  else
  echo "Error: pcre-8.12.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/pcre-8.12.tar.gz
fi

if [ "$isinstallTCMalloc" = "n" ]; then
	if [ -s jemalloc-3.4.0.tar.bz2 ]; then
	  echo "jemalloc-3.4.0.tar.bz2 [found]"
	else
	  echo "Error: jemalloc-3.4.0.tar.bz2 not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/jemalloc-3.4.0.tar.bz2
	fi
else
	if [ -s gperftools-2.1.tar.gz ]; then
	  echo "gperftools-2.1.tar.gz [found]"
	  else
	  echo "Error: gperftools-2.1.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/gperftools-2.1.tar.gz
	fi
fi

if [ "$isinstallTengine" = "n" ]; then
	if [ -s nginx-1.5.9.tar.gz ]; then
	  echo "nginx-1.5.9.tar.gz [found]"
	  else
	  echo "Error: nginx-1.5.9.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/nginx-1.5.9.tar.gz
	fi
else
	if [ -s tengine-2.0.0.tar.gz ]; then
	  echo "tengine-2.0.0.tar.gz [found]"
	  else
	  echo "Error: tengine-2.0.0.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/tengine-2.0.0.tar.gz
	fi
fi

if [ "$isinstallMariadb" = "n" ]; then
	if [ -s mysql-5.5.35.tar.gz ]; then
	  echo "mysql-5.5.35.tar.gz [found]"
	  else
	  echo "Error: mysql-5.5.35.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/mysql-5.5.35.tar.gz
	fi
else
	if [ -s mariadb-5.5.33a.tar.gz ]; then
	  echo "mariadb-5.5.33a.tar.gz [found]"
	  else
	  echo "Error: mariadb-5.5.33a.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/mariadb-5.5.33a.tar.gz
	fi
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
  else
  echo "Error: libiconv-1.14.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/libiconv-1.14.tar.gz
fi

if [ -s libmcrypt-2.5.8.tar.gz ]; then
  echo "libmcrypt-2.5.8.tar.gz [found]"
  else
  echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
  wget -c  http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/libmcrypt-2.5.8.tar.gz
fi

if [ -s mhash-0.9.9.9.tar.gz ]; then
  echo "mhash-0.9.9.9.tar.gz [found]"
  else
  echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/mhash-0.9.9.9.tar.gz
fi

if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
  else
  echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/mcrypt-2.6.8.tar.gz
fi

if [ -s phpMyAdmin-4.1.7-all-languages.tar.gz ]; then
  echo "phpMyAdmin-4.1.7-all-languages.tar.gz [found]"
  else
  echo "Error: phpMyAdmin-4.1.7-all-languages.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/phpMyAdmin-4.1.7-all-languages.tar.gz
fi

if [ -s p.tar.gz ]; then
  echo "p.tar.gz [found]"
  else
  echo "Error: p.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/p.tar.gz
fi

if [ -s autoconf-2.13.tar.gz ]; then
  echo "autoconf-2.13.tar.gz [found]"
  else
  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/autoconf-2.13.tar.gz
fi
echo "============================check files=================================="
}

function InstallDependsAndOpt()
{
cd $cur_dir

tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

cd $cur_dir
tar zxvf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure --enable-static
make && make install
cd ../

cd $cur_dir
tar zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

cd $cur_dir
tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

cd $cur_dir
tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof

}
function Installjemalloc()
{
echo "============================jemalloc install================================="
cd $cur_dir
tar xjf jemalloc-3.4.0.tar.bz2
cd jemalloc-3.4.0
./configure
make && make install
cd ../

echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig
echo "=========================== jemalloc intall completed ========================"
}
function Installgperftools()
{
echo "============================gperftools install================================="
bit=$(getconf LONG_BIT)
if [ "$bit" = "64" ]; then
cd $cur_dir
if [ -s libunwind-1.1.tar.gz ]; then
  echo "libunwind-1.1.tar.gz [found]"
else
  echo "Error: libunwind-1.1.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/libunwind-1.1.tar.gz
fi
tar zxvf libunwind-1.1.tar.gz
cd libunwind-1.1
CFLAGS=-fPIC ./configure
make CFLAGS=-fPIC
make CFLAGS=-fPIC install
make && make install
cd ../
fi

cd $cur_dir
tar zxvf gperftools-2.1.tar.gz
cd gperftools-2.1
./configure --prefix=/usr/local --enable-shared --enable-frame-pointers
make && make install
cd ../

echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf
/sbin/ldconfig
echo "=========================== gperftools intall completed ========================"
}
function InstallMySQL()
{
echo "============================Install MySQL =================================="
cd $cur_dir
rm /etc/my.cnf
rm /etc/mysql/my.cnf
rm -rf /etc/mysql/

cd $cur_dir
tar zxvf mysql-5.5.35.tar.gz
cd mysql-5.5.35/
if [ "$isinstallTCMalloc" == 'n' ];then
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EXTRA_CHARSETS=complex -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DCMAKE_EXE_LINKER_FLAGS="-ljemalloc" -DWITH_SAFEMALLOC=OFF
elif [ "$isinstallTCMalloc" == 'y' ];then
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EXTRA_CHARSETS=complex -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DCMAKE_EXE_LINKER_FLAGS="-ltcmalloc" -DWITH_SAFEMALLOC=OFF
fi
make && make install

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp support-files/my-medium.cnf /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
else
sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
fi

/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
chown -R mysql /usr/local/mysql/data
chgrp -R mysql /usr/local/mysql/.
cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password='';
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

sed -i 's/log-bin=mysql-bin/# log-bin=mysql-bin/g' /etc/my.cnf
sed -i 's/binlog_format=mixed/# binlog_format=mixed/g' /etc/my.cnf

/etc/init.d/mysql restart
/etc/init.d/mysql stop

echo "============================MySQL install completed========================="
}
function InstallMariadb()
{
echo "============================Install Mariadb =================================="
cd $cur_dir

rm /etc/my.cnf
rm /etc/mysql/my.cnf
rm -rf /etc/mysql/
tar zxvf mariadb-5.5.33a.tar.gz
cd mariadb-5.5.33a/
if [ "$isinstallTCMalloc" == 'n' ];then
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=0 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATEDX_STORAGE_ENGINE=1 -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_EXTRA_CHARSETS=all -DWITH_LIBWRAP=1 -DWITH_EXTRA_CHARSETS=complex -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DCMAKE_EXE_LINKER_FLAGS="-ljemalloc" -DWITH_SAFEMALLOC=OFF
elif [ "$isinstallTCMalloc" == 'y' ];then
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=0 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATEDX_STORAGE_ENGINE=1 -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_EXTRA_CHARSETS=all -DWITH_LIBWRAP=1 -DWITH_EXTRA_CHARSETS=complex -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DCMAKE_EXE_LINKER_FLAGS="-ltcmalloc" -DWITH_SAFEMALLOC=OFF
fi
make && make install

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cp support-files/my-medium.cnf /etc/my.cnf
if [ $installinnodb = "y" ]; then
sed -i 's:#innodb:innodb:g' /etc/my.cnf
else
sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
fi

/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
chown -R mysql /usr/local/mysql/data
chgrp -R mysql /usr/local/mysql/.
cp support-files/mysql.server /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi
/etc/init.d/mysql start

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

/usr/local/mysql/bin/mysqladmin -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password='';
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

sed -i 's/log-bin=mysql-bin/# log-bin=mysql-bin/g' /etc/my.cnf
sed -i 's/binlog_format=mixed/# binlog_format=mixed/g' /etc/my.cnf

/etc/init.d/mysql restart
/etc/init.d/mysql stop
echo "============================Mariadb install completed========================="
}
function InstallPHP53()
{
echo "============================Install PHP 5.3.28========================="
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-5.3.28.tar.gz
cd php-5.3.28/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $cur_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php/etc/php.ini

echo "Install ZendGuardLoader for PHP 5.3"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	if [ -s ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz ]; then
	  echo "ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz [found]"
	  else
	  echo "Error: ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	fi
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
else
	if [ -s ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz ]; then
	  echo "ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz [found]"
	  else
	  echo "Error: ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	fi
	tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
fi

echo "Write ZendGuardLoader to php.ini......"
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_loader.enable = 1
zend_extension=/usr/local/zend/ZendGuardLoader.so
EOF

echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-5.3.28/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/ltnmp /root/ltnmp
chmod +x /root/ltnmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/ltnmp
echo "============================PHP 5.3.28 install completed======================"
}
function InstallPHP54()
{
echo "============================Install PHP 5.4.24================================"
cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-5.4.24.tar.gz
cd php-5.4.24/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $cur_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php/etc/php.ini

echo "Install ZendGuardLoader for PHP 5.4"
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	if [ -s ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz ]; then
	  echo "ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz [found]"
	else
	  echo "Error: ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
	fi
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
else
	if [ -s ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz ]; then
	  echo "ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz [found]"
	else
	  echo "Error: ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz not found!!!download now......"
	  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
	fi
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
fi

echo "Write ZendGuardLoader to php.ini......"
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_loader.enable = 1
zend_extension=/usr/local/zend/ZendGuardLoader.so
EOF

echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-5.4.24/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

cp $cur_dir/ltnmp /root/ltnmp
chmod +x /root/ltnmp
sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/ltnmp
echo "============================PHP 5.4.20 install completed======================"
}
function InstallNginx()
{
echo "============================Install Nginx================================="
cd $cur_dir
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

cd $cur_dir
tar zxvf nginx-1.5.9.tar.gz
cd nginx-1.5.9/
if [ "$isinstallTCMalloc" == 'n' ];then
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-ld-opt="-ljemalloc"
elif [ "$isinstallTCMalloc" == 'y' ];then
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-google_perftools_module
fi
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

cd $cur_dir
rm -f /usr/local/nginx/conf/nginx.conf
cp conf/nginx.conf /usr/local/nginx/conf/nginx.conf
cp conf/dabr.conf /usr/local/nginx/conf/dabr.conf
cp conf/discuz.conf /usr/local/nginx/conf/discuz.conf
cp conf/sablog.conf /usr/local/nginx/conf/sablog.conf
cp conf/typecho.conf /usr/local/nginx/conf/typecho.conf
cp conf/wordpress.conf /usr/local/nginx/conf/wordpress.conf
cp conf/discuzx.conf /usr/local/nginx/conf/discuzx.conf
cp conf/none.conf /usr/local/nginx/conf/none.conf
cp conf/wp2.conf /usr/local/nginx/conf/wp2.conf
cp conf/phpwind.conf /usr/local/nginx/conf/phpwind.conf
cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
cp conf/shopex.conf /usr/local/nginx/conf/shopex.conf
cp conf/dedecms.conf /usr/local/nginx/conf/dedecms.conf
cp conf/drupal.conf /usr/local/nginx/conf/drupal.conf
cp conf/ecshop.conf /usr/local/nginx/conf/ecshop.conf

rm -f /usr/local/nginx/conf/fcgi.conf
cp conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf
echo "============================Nginx install completed======================"
}

function InstallTengine()
{
echo "============================Install Tengine================================="
cd $cur_dir
tar zxvf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

cd $cur_dir
tar zxvf tengine-2.0.0.tar.gz
cd tengine-2.0.0/
if [ "$isinstallTCMalloc" == 'n' ];then
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sysguard_module --with-http_concat_module --with-jemalloc
elif [ "$isinstallTCMalloc" == 'y' ];then
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sysguard_module --with-http_concat_module --with-google_perftools_module
fi
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

cd $cur_dir
rm -f /usr/local/nginx/conf/nginx.conf
cp conf/tengine.conf /usr/local/nginx/conf/tengine.conf
cp conf/dabr.conf /usr/local/nginx/conf/dabr.conf
cp conf/discuz.conf /usr/local/nginx/conf/discuz.conf
cp conf/sablog.conf /usr/local/nginx/conf/sablog.conf
cp conf/typecho.conf /usr/local/nginx/conf/typecho.conf
cp conf/wordpress.conf /usr/local/nginx/conf/wordpress.conf
cp conf/discuzx.conf /usr/local/nginx/conf/discuzx.conf
cp conf/none.conf /usr/local/nginx/conf/none.conf
cp conf/wp2.conf /usr/local/nginx/conf/wp2.conf
cp conf/phpwind.conf /usr/local/nginx/conf/phpwind.conf
cp conf/pathinfo.conf /usr/local/nginx/conf/pathinfo.conf
cp conf/shopex.conf /usr/local/nginx/conf/shopex.conf
cp conf/dedecms.conf /usr/local/nginx/conf/dedecms.conf
cp conf/drupal.conf /usr/local/nginx/conf/drupal.conf
cp conf/ecshop.conf /usr/local/nginx/conf/ecshop.conf
mv /usr/local/nginx/conf/tengine.conf /usr/local/nginx/conf/nginx.conf

rm -f /usr/local/nginx/conf/fcgi.conf
cp conf/fcgi.conf /usr/local/nginx/conf/fcgi.conf
echo "============================Tengine install completed======================"
}
function CreatPHPTools()
{
echo "==================== Optimization ==========================="
if [ "$isinstallTCMalloc" == 'n' ];then
sed -i '/export LD_PRELOAD=/d' /usr/local/mysql/bin/mysqld_safe
sed -i '/executing mysqld_safe'/a\ "export LD_PRELOAD=\/usr\/local\/lib\/libjemalloc.so" /usr/local/mysql/bin/mysqld_safe
elif [ "$isinstallTCMalloc" == 'y' ];then
sed -i '/google_perftools_profiles/d' /usr/local/nginx/conf/nginx.conf
sed -i '/nginx.pid'/a\ "google_perftools_profiles \/tmp\/tcmalloc;" /usr/local/nginx/conf/nginx.conf
sed -i '/export LD_PRELOAD=/d' /usr/local/mysql/bin/mysqld_safe
sed -i '/executing mysqld_safe'/a\ "export LD_PRELOAD=\/usr\/local\/lib\/libtcmalloc.so" /usr/local/mysql/bin/mysqld_safe
fi

groupadd www
useradd -s /sbin/nologin -g www www

mkdir -p /home/www/default
chmod +w /home/www/default
mkdir -p /home/wwwlogs
chmod 777 /home/wwwlogs
touch /home/wwwlogs/nginx_error.log

cd $cur_dir
chown -R www:www /home/www/default
echo "======================= phpMyAdmin install ============================"
cd $cur_dir
tar zxvf phpMyAdmin-4.1.7-all-languages.tar.gz
mv phpMyAdmin-4.1.7-all-languages /home/www/default/phpmyadmin/
cp conf/config.inc.php /home/www/default/phpmyadmin/config.inc.php
sed -i 's/PHP360/php360'$RANDOM'05gzs.com/g' /home/www/default/phpmyadmin/config.inc.php
mkdir /home/www/default/phpmyadmin/upload/
mkdir /home/www/default/phpmyadmin/save/
chmod 755 -R /home/www/default/phpmyadmin/
chown www:www -R /home/www/default/phpmyadmin/
echo "==================== phpMyAdmin install completed ======================"
echo "Copy PHP Prober..."
tar zxvf p.tar.gz
cp p.php /home/www/default/p.php
cp conf/ltnmp.gif /home/www/default/ltnmp.gif
cp conf/index.html /home/www/default/index.html
}
function AddAndStartup()
{
echo "============================add nginx and php-fpm on startup============================"
#start up
echo "Download new nginx init.d file......"
if [ -s init.d.nginx ]; then
    echo "init.d.nginx [found]"
else
    echo "Error: init.d.nginx not found!!!download now......"
    wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/init.d.nginx
fi
cp init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
chkconfig --level 345 mysql on
cd $cur_dir
cp vhost.sh /root/vhost.sh
chmod +x /root/vhost.sh
chmod 0751 /home/www
chmod 0751 /home
echo "===========================add nginx and php-fpm on startup completed===================="
echo "Starting LTNMP..."
/etc/init.d/mysql start
/etc/init.d/php-fpm start
/etc/init.d/nginx start

#add 80 port to iptables
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/sbin/iptables-save
fi
}
function CheckInstall()
{
echo "===================================== Check install ==================================="
clear
isnginx=""
ismysql=""
isphp=""
echo "Checking..."
if [ -s /usr/local/nginx ] && [ -s /usr/local/nginx/sbin/nginx ]; then
  echo "Nginx: OK"
  isnginx="ok"
  else
  echo "Error: /usr/local/nginx not found!!!Nginx install failed."
fi

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
  echo "PHP: OK"
  echo "PHP-FPM: OK"
  isphp="ok"
  else
  echo "Error: /usr/local/php not found!!!PHP install failed."
fi

if [ -s /usr/local/mysql ] && [ -s /usr/local/mysql/bin/mysql ]; then
  echo "MySQL: OK"
  ismysql="ok"
  else
  echo "Error: /usr/local/mysql not found!!!MySQL install failed."
fi
if [ "$isnginx" = "ok" ] && [ "$ismysql" = "ok" ] && [ "$isphp" = "ok" ]; then
echo "Install LTNMP completed! enjoy it."
echo "========================================================================="
echo "LTNMP for CentOS/RadHat Linux VPS  Written by PHP360 "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "ltanmp status manage: /root/ltnmp {start|stop|reload|restart|kill|status}"
echo "default mysql root password:$mysqlrootpwd"
echo "phpMyAdmin : http://yourIP/phpmyadmin/"
echo "Prober : http://yourIP/p.php"
echo "Add VirtualHost : /root/vhost.sh"
echo ""
echo "The path of some dirs:"
echo "mysql dir:   /usr/local/mysql"
echo "php dir:     /usr/local/php"
echo "nginx dir:   /usr/local/nginx"
echo "web dir :     /home/www/default"
echo ""
echo "========================================================================="
/root/ltnmp status
netstat -ntl
else
  echo "Sorry,Failed to install LTNMP!"
echo "Please visit http://www.05gzs.com/forum-help-1.html feedback errors and logs."
echo "You can download /root/ltnmp-install.log from your server,and upload ltnmp-install.log to LTNMP Forum."
fi
}

InitInstall 2>&1 | tee /root/ltnmp-install.log
CheckAndDownloadFiles 2>&1 | tee -a /root/ltnmp-install.log
InstallDependsAndOpt 2>&1 | tee -a /root/ltnmp-install.log
if [ "$isinstallTCMalloc" = "n" ]; then
	Installjemalloc 2>&1 | tee -a /root/ltnmp-install.log
else
	Installgperftools 2>&1 | tee -a /root/ltnmp-install.log
fi
if [ "$isinstallMariadb" = "n" ]; then
	InstallMySQL 2>&1 | tee -a /root/ltnmp-install.log
else
	InstallMariadb 2>&1 | tee -a /root/ltnmp-install.log
fi
if [ "$isinstallphp" = "n" ]; then
	InstallPHP53 2>&1 | tee -a /root/ltnmp-install.log
else
	InstallPHP54 2>&1 | tee -a /root/ltnmp-install.log
fi
if [ "$isinstallTengine" = "n" ]; then
	InstallNginx 2>&1 | tee -a /root/ltnmp-install.log
else
	InstallTengine 2>&1 | tee -a /root/ltnmp-install.log
fi
CreatPHPTools 2>&1 | tee -a /root/ltnmp-install.log
AddAndStartup 2>&1 | tee -a /root/ltnmp-install.log
CheckInstall 2>&1 | tee -a /root/ltnmp-install.log