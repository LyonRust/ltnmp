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
echo "Upgrade PHP for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP+Apache on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
cur_dir=$(pwd)

if [ "$1" != "--help" ]; then

old_php_version=`/usr/local/php/bin/php -r 'echo PHP_VERSION;'`
#echo $old_php_version

#set php version

	php_version=""
	echo "Current PHP Version:$old_php_version"
	echo "You can get version number from http://www.php.net/"
	read -p "(Please input PHP Version you want):" php_version
	if [ "$php_version" = "" ]; then
		echo "Error: You must input php version!!"
		exit 1
	fi

	if [ "$php_version" = "$old_php_version" ]; then
		echo "Error: The upgrade PHP Version is the same as the old Version!!"
		exit 1
	fi
	echo "==========================="

	echo "You want to upgrade php version to $php_version"

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
if [ -s php-$php_version.tar.gz ]; then
  echo "php-$php_version.tar.gz [found]"
  else
  echo "Error: php-$php_version.tar.gz not found!!!download now......"
  wget -c http://us2.php.net/distributions/php-$php_version.tar.gz
  if [ $? -eq 0 ]; then
	echo "Download php-$php_version.tar.gz successfully!"
  else
	echo "WARNING!May be the php version you input was wrong,please check!"
	echo "PHP Version input was:"$php_version
	sleep 5
	exit 1
  fi
fi
echo "============================check files=================================="

#Backup old php version configure files
echo "Backup old php version configure files......"
/etc/init.d/httpd stop
mkdir -p /root/phpconf
cp /usr/local/php/etc/php.ini /root/phpconf/php.ini.old.bak
rm -rf /usr/local/php/
cp /usr/local/apache/modules/libphp5.so /root/phpconf/
rm -f /usr/local/apache/modules/libphp5.so

echo "Stoping Nginx..."
/etc/init.d/nginx stop
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping Apache..."
/etc/init.d/httpd stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

cd $cur_dir
echo "Starting install php......"
if [ -s php-$php_version/ ]; then
rm -rf php-$php_version/
fi
tar zxvf php-$php_version.tar.gz
cd php-$php_version/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs with-libevent-dir --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

rm -f libtool
cp /usr/local/apache/build/libtool .

make ZEND_EXTRA_LIBS='-liconv'
make install

mkdir -p /usr/local/php/etc/
rm -f /usr/local/php/etc/php.ini
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
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php/etc/php.ini

echo "Install ZendGuardLoader for PHP..."
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	if [[ "$php_version" =~ "5.3." ]]; then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
	elif [[ "$php_version" =~ "5.4." ]]; then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
	fi
else
	if [[ "$php_version" =~ "5.3." ]]; then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/
	elif [[ "$php_version" =~ "5.4." ]]; then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/zend/
	fi
fi

echo "Write ZendGuardLoader to php.ini......"
cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_loader.enable = 1
zend_extension=/usr/local/zend/ZendGuardLoader.so
EOF

echo "Starting Nginx..."
/etc/init.d/nginx start
echo "Starting MySQL..."
/etc/init.d/mysql start
echo "Starting Apache..."
/etc/init.d/httpd start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi

cd $cur_dir

echo "========================================================================="
echo "You have successfully upgrade PHP of LTNMP from $old_php_version to $php_version"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+MySQL+PHP+Apache on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="
fi
