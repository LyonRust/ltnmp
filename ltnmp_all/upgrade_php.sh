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
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
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

	if [ "$php_version" == "$old_php_version" ]; then
		echo "Error: The upgrade PHP Version is the same as the old Version!!"
		exit 1
	fi
	echo "=================================================="
	echo "You want to upgrade php version to $php_version"
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
	echo "Press any key to start...or Press Ctrl+c to cancel"
	char=`get_char`

echo "============================check files=================================="
if [ -s php-$php_version.tar.gz ]; then
  echo "php-$php_version.tar.gz [found]"
  else
  echo "Error: php-$php_version.tar.gz not found!!!download now......"
  wget -c http://www.php.net/distributions/php-$php_version.tar.gz
  if [ $? -eq 0 ]; then
	echo "Download php-$php_version.tar.gz successfully!"
  else
	echo "WARNING!May be the php version you input was wrong,please check!"
	echo "PHP Version input was:"$php_version
	sleep 5
	exit 1
  fi
fi

if [ -s autoconf-2.13.tar.gz ]; then
  echo "autoconf-2.13.tar.gz [found]"
  else
  echo "Error: autoconf-2.13.tar.gz not found!!!download now......"
  wget -c http://www.05gzs.com/ltnmp/autoconf-2.13.tar.gz
  #wget -c http://ltanmp.googlecode.com/files/autoconf-2.13.tar.gz
fi
echo "============================check files=================================="

echo "Stoping Nginx..."
/etc/init.d/nginx stop
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

rm -rf php-$php_version/

tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

ln -s /usr/lib/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib/libltdl.so /usr/lib/libltdl.so.3

if [ $php_version = "5.2.14" ] || [ $php_version = "5.2.15" ] || [ $php_version = "5.2.16" ] || [ $php_version = "5.2.17" ]; then

if [ -s php-$php_version-fpm-0.5.14.diff.gz ]; then
  echo "php-$php_version-fpm-0.5.14.diff.gz [found]"
  else
  echo "Error: php-$php_version-fpm-0.5.14.diff.gz not found!!!download now......"
  wget -c http://php-fpm.org/downloads/php-$php_version-fpm-0.5.14.diff.gz
fi

cd $cur_dir
echo "Stop php-fpm....."
if [ -s /usr/local/php/sbin/php-fpm ]; then
/usr/local/php/sbin/php-fpm stop
else
/etc/init.d/php-fpm stop
fi

echo "Start install php-$php_version....."
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-$php_version.tar.gz
gzip -cd php-$php_version-fpm-0.5.14.diff.gz | patch -d php-$php_version -p1
cd php-$php_version/
wget -c http://www.05gzs.com/ltnmp/php-5.2.17-max-input-vars.patch
#wget -c http://ltanmp.googlecode.com/files/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch
./buildconf --force
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
    wget -c http://www.05gzs.com/ltnmp/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    #wget -c http://ltanmp.googlecode.com/files/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

/usr/local/php/sbin/php-fpm start
wget -c http://www.05gzs.com/ltnmp/init.d.php-fpm5.2
#wget -c http://ltanmp.googlecode.com/files/init.d.php-fpm5.2
cp init.d.php-fpm5.2 /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

sleep 2

elif [ $php_version = "5.3.0" ] || [ $php_version = "5.3.1" ] || [ $php_version = "5.3.2" ]; then

echo "DO NOT SUPPORT PHP VERSION :$php_version"
echo "Waiting for script to EXIT......"
sleep 2
exit 1

else

#Backup old php version configure files
echo "Backup old php version configure files......"
mkdir -p /root/phpconf
cp /usr/local/php/etc/php-fpm.conf /root/phpconf/php-fpm.conf.old.bak
cp /usr/local/php/etc/php.ini /root/phpconf/php.ini.old.bak
cp /root/lnmp /root/phpconf/lnmp
rm -f /root/lnmp
/usr/local/php/sbin/php-fpm stop
rm -rf /usr/local/php/
cp /etc/init.d/php-fpm /root/phpconf/php-fpm.old.bak
rm -f /etc/init.d/php-fpm

cd $cur_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader

echo "Starting install php......"
tar zxvf php-$php_version.tar.gz
cd php-$php_version/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

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
pm.max_children = 20
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

echo "Copy php-fpm init.d file......"
cp $cur_dir/php-$php_version/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

echo "download new lnmp manager......"
wget -c http://www.05gzs.com/ltnmp/ltanmp4php5.3
#wget -c http://ltanmp.googlecode.com/files/ltanmp4php5.3
cp ltanmp4php5.3 /root/ltnmp
chmod +x /root/ltnmp


echo "Remove old start files and Add new start file....."
if [ -s /etc/debian_version ]; then
update-rc.d -f nginx.sh remove
if [ -s /etc/init.d/nginx.sh ]; then
  echo "Download new nginx init.d file......"
  wget -c http://www.05gzs.com/ltnmp/init.d.nginx
  #wget -c http://ltanmp.googlecode.com/files/init.d.nginx
  cp init.d.nginx /etc/init.d/nginx
  chmod +x /etc/init.d/nginx
  rm -f /etc/init.d/nginx.sh
  update-rc.d -f nginx defaults
fi
update-rc.d -f php-fpm defaults
elif [ -s /etc/redhat-release ]; then
sed -i '/php-fpm/'d /etc/rc.local
sed -i '/nginx/'d /etc/rc.local
#echo "/etc/init.d/nginx start" >>/etc/rc.local
#echo "/etc/init.d/php-fpm start" >>/etc/rc.local
chkconfig --level 345 php-fpm on
chkconfig --level 345 nginx on
fi

echo "Starting Nginx..."
/etc/init.d/nginx start
echo "Starting MySQL..."
/etc/init.d/mysql start
echo "Starting PHP-FPM..."
/etc/init.d/php-fpm start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi

fi

cd $cur_dir

echo "========================================================================="
echo "You have successfully upgrade from $old_php_version to $php_version"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="
fi