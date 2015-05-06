#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install PHP5.* for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install PHP5.* for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"
echo ""
cur_dir=$(pwd)

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ] && [ -s /etc/init.d/php-fpm ]; then
	echo "PHP Default file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php52/sbin/php-fpm ] && [ -s /usr/local/php52/etc/php.ini ] && [ -s /usr/local/php52/bin/php ] && [ -s /etc/init.d/php-fpm52 ]; then
	echo "PHP52   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php53/sbin/php-fpm ] && [ -s /usr/local/php53/etc/php.ini ] && [ -s /usr/local/php53/bin/php ] && [ -s /etc/init.d/php-fpm53 ]; then
	echo "PHP53   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php54/sbin/php-fpm ] && [ -s /usr/local/php54/etc/php.ini ] && [ -s /usr/local/php54/bin/php ] && [ -s /etc/init.d/php-fpm54 ]; then
	echo "PHP54   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php55/sbin/php-fpm ] && [ -s /usr/local/php55/etc/php.ini ] && [ -s /usr/local/php55/bin/php ] && [ -s /etc/init.d/php-fpm55 ]; then
	echo "PHP55   ver file php-fpm [found] Install is OK  "
fi
	echo ""



	ver="1"
	ver0="Install"

	echo "Add or Del  PHP 5.*.*  do you want :"
	echo "Install PHP 5.*.* Ver     please type: 1"
	echo "Delete  PHP 5.*.* Ver	  please type: 0"
	echo ""
	read -p "Type 1 or 0 (Default: 1):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="1"
	fi

	if [ "$ver" != 1 ] && [ "$ver" != 0 ]; then
	echo "Error: You must input  1 or 0!!"
	exit 1
	fi

	if [ "$ver" = "0" ]; then

		echo "You will Delete  PHP 5.*.* Ver !!"
		ver0="Delete"
	fi




#-----------Delete  PHP 5.*.* Ver

if [ "$ver" = 0 ] ; then

	read -p "Please input DEL php ver ( 55 or 54 or 53 or 52 ):" delphp_ver
	if [ "$delphp_ver" = "" ]; then
		echo "You must input  Del php VER !"
		exit 1
	fi
	echo "==========================="
	echo "delphp_ver = $delphp_ver"
	echo "==========================="


	if [ "$delphp_ver" = "52" ] || [ "$delphp_ver" = "53" ] || [ "$delphp_ver" = "54" ] || [ "$delphp_ver" = "55" ];then
	echo "You will Delete  PHP $delphp_ver Ver !!"
	else
	echo "DO NOT SUPPORT php VERSION :$delphp_ver ,  Do not PHP $delphp_ver Ver"
	echo "Waiting for script to EXIT......"
	exit 1
	fi

	ver1="$delphp_ver"


if [ -s /usr/local/php$ver1/sbin/php-fpm ] && [ -s /usr/local/php$ver1/etc/php.ini ] && [ -s /usr/local/php$ver1/bin/php ]; then
	echo "PHP$ver1 php-fpm ver file [found] "
	echo ""

	else
	echo "PHP$ver1 php-fpm ver file not found  EXIT ! "
	echo ""
	exit 1
fi



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
	echo "Press any key to $ver0 PHP $ver1 Ver ...or Press Ctrl+c to cancel"
	char=`get_char`



echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm$ver1 stop


echo "Remove start file....."


if [ -s /etc/debian_version ]; then
sed -i "/php-fpm$ver1/"d /etc/init.d/rc.local

elif [ -s /etc/redhat-release ]; then
sed -i "/php-fpm$ver1/"d /etc/rc.local
chkconfig --level 345 php-fpm$ver1 off

fi





rm /etc/init.d/php-fpm$ver1
rm -rf /usr/local/php$ver1/

echo ""
/usr/local/php/bin/php  -v
echo ""

exit 1

fi




#-----------set PHP 5.*.* Ver

if [ "$ver" = 1 ] ; then

	php_versiona="5.5.0"
	echo "Please input php ver:"
	read -p "(Default PHP 5.*.* ver: $php_versiona):" php_version
	if [ "$php_version" = "" ]; then
		php_version=$php_versiona
	fi
	echo "==========================="
	echo "php_ver = $php_version"
	echo "==========================="


	if echo $php_version | grep -q "5.2.17"||echo $php_version | grep -q "5.3.*"||echo $php_version | grep -q "5.4.*"||echo $php_version | grep -q "5.5.*";then
	echo "You will install PHP 5.*.* Ver !!"
	else
	echo "DO NOT SUPPORT php VERSION :$php_version ,  Do not PHP 5.*.* Ver"
	echo "Waiting for script to EXIT......"
	exit 1
	fi


	ver1="55"
	if   echo $php_version | grep -q "5.2.*"; then ver1="52"
	elif echo $php_version | grep -q "5.3.*"; then ver1="53"
	elif echo $php_version | grep -q "5.4.*"; then ver1="54"
	elif echo $php_version | grep -q "5.5.*"; then ver1="55"
	fi


echo ""
cur_php_version=`/usr/local/php/bin/php -v`
echo "Current PHP Version:$cur_php_version"

	if echo $cur_php_version | grep -q "$php_version"; then
	   echo ""
	   echo "Do NOT need to install PHP $php_version !"
	   exit 1
	fi

fi




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
	echo "Press any key to $ver0 PHP $php_version Ver ...or Press Ctrl+c to cancel"
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
	echo "WARNING!May be the PHP version you input was wrong,please check!"
	echo ""
	echo "You can get PHP version number from http://www.php.net/"
	echo ""
	echo "PHP Version input was:"$php_version
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


tar zxvf autoconf-2.13.tar.gz
cd autoconf-2.13/
./configure --prefix=/usr/local/autoconf-2.13
make && make install
cd ../

ln -s /usr/lib/libevent-1.4.so.2 /usr/local/lib/libevent-1.4.so.2
ln -s /usr/lib/libltdl.so /usr/lib/libltdl.so.3








if [ "$php_version" = "5.2.17" ];then

echo "============================install 5.2.17 =================================="


if [ -s php-5.2.17-fpm-0.5.14.diff.gz ]; then
  echo "php-5.2.17-fpm-0.5.14.diff.gz [found]"
  else
  echo "Error: php-5.2.17-fpm-0.5.14.diff.gz not found!!!download now......"
  wget -c http://www.05gzs.com/ltnmp/php-5.2.17-fpm-0.5.14.diff.gz
  #wget -c http://ltanmp.googlecode.com/files/php-5.2.17-fpm-0.5.14.diff.gz
fi



cd $cur_dir

rm -rf php-5.2.17/

echo "Start install php-5.2.17....."
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxvf php-5.2.17.tar.gz
gzip -cd php-5.2.17-fpm-0.5.14.diff.gz | patch -d php-5.2.17 -p1
cd php-5.2.17/
wget -c http://www.05gzs.com/ltnmp/php-5.2.17-max-input-vars.patch
#wget -c http://ltanmp.googlecode.com/files/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch
./buildconf --force
./configure --prefix=/usr/local/php52 --with-config-file-path=/usr/local/php52/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic
if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
    wget -c http://www.05gzs.com/ltnmp/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    #wget -c http://ltanmp.googlecode.com/files/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

cp php.ini-dist /usr/local/php52/etc/php.ini

cd $cur_dir/php-5.2.17/ext/pdo_mysql/
/usr/local/php52/bin/phpize
./configure --with-php-config=/usr/local/php52/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd $cur_dir/

# php extensions
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php52/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "pdo_mysql.so"\n#' /usr/local/php52/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php52/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php52/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php52/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php52/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php52/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php$ver1/etc/php.ini

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    wget -c http://www.05gzs.com/ltnmp/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    #wget -c http://ltanmp.googlecode.com/files/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
    tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
else
    wget -c http://www.05gzs.com/ltnmp/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
    #wget -c http://ltanmp.googlecode.com/files/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
fi

cat >>/usr/local/php52/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_optimizer.optimization_level=1
zend_extension="/usr/local/zend/ZendOptimizer.so"
EOF

rm -f /usr/local/php52/etc/php-fpm.conf
wget -c http://www.05gzs.com/ltnmp/php-fpm.conf
#wget -c http://ltanmp.googlecode.com/files/php-fpm.conf
cp php-fpm.conf /usr/local/php52/etc/php-fpm.conf

/usr/local/php52/sbin/php-fpm start
wget -c http://www.05gzs.com/ltnmp/init.d.php-fpm5.2
#wget -c http://ltanmp.googlecode.com/files/init.d.php-fpm5.2
cp init.d.php-fpm5.2 /etc/init.d/php-fpm52
chmod +x /etc/init.d/php-fpm52

sed -i 's#/usr/local/php/#/usr/local/php52/#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#php-cgi.sock#php-cgi52.sock#g' /usr/local/php52/etc/php-fpm.conf
sed -i 's#/usr/local/php/#/usr/local/php52/#g' /etc/init.d/php-fpm52


fi







if echo $php_version | grep -q "5.3.*"||echo $php_version | grep -q "5.4.*"||echo $php_version | grep -q "5.5.*";then

echo "============================install 5.3+ =================================="

cd $cur_dir
rm -rf php-$php_version/

echo "Starting install php......"
tar zxvf php-$php_version.tar.gz
cd php-$php_version/
./buildconf --force > testbuildconf

if grep -q "autoconf-2.13" testbuildconf;
then
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
./buildconf --force
else
echo "It looks like working.";
cat testbuildconf
fi

./configure --prefix=/usr/local/php$ver1 --with-config-file-path=/usr/local/php$ver1/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

echo "Copy new php configure file."
mkdir -p /usr/local/php$ver1/etc
cp php.ini-production /usr/local/php$ver1/etc/php.ini



# php extensions
echo "Modify php.ini......"
sed -i 's/display_errors = Off/display_errors = On/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/enable_dl = Off/enable_dl = On/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 50M/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php$ver1/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php$ver1/etc/php.ini


echo "Install ZendGuardLoader for PHP..."
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	if echo $php_version | grep -q "5.3.*";then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader53.so
	elif echo $php_version | grep -q "5.4.*";then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader54.so
	fi
else
	if echo $php_version | grep -q "5.3.*";then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		tar zxvf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader53.so
	elif echo $php_version | grep -q "5.4.*";then
		wget -c http://www.05gzs.com/ltnmp/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		#wget -c http://ltanmp.googlecode.com/files/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		tar zxvf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		mkdir -p /usr/local/zend/
		\cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so /usr/local/zend/ZendGuardLoader54.so
	fi
fi




echo "Write ZendGuardLoader to php.ini......"

if echo $php_version | grep -q "5.5.*";then

cat >>/usr/local/php$ver1/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
;zend_extension=/usr/local/zend/ZendGuardLoader$ver1.so
EOF

else

cat >>/usr/local/php$ver1/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_extension=/usr/local/zend/ZendGuardLoader$ver1.so
EOF

fi





echo "Creating new php-fpm configure file......"
cat >/usr/local/php$ver1/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php$ver1/var/run/php-fpm.pid
error_log = /usr/local/php$ver1/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi$ver1.sock
user = www
group = www
pm = dynamic
pm.max_children = 40
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 2048
request_terminate_timeout = 120
pm.process_idle_timeout = 10
EOF

echo "Copy php-fpm$ver1 init.d file......"
cp $cur_dir/php-$php_version/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm$ver1
chmod +x /etc/init.d/php-fpm$ver1



echo "============================install 5.3+ completed==========================="

fi





echo "Remove old start files and Add new start file....."

if [ -s /etc/debian_version ]; then
sed -i "/php-fpm$ver1/"d /etc/init.d/rc.local
echo "/etc/init.d/php-fpm$ver1  start">>/etc/init.d/rc.local

elif [ -s /etc/redhat-release ]; then
sed -i "/php-fpm$ver1/"d /etc/rc.local
echo "/etc/init.d/php-fpm$ver1 start" >>/etc/rc.local
chkconfig --level 345 php-fpm$ver1 on

fi







echo "Stop LTNMP..."
/etc/init.d/nginx stop
/etc/init.d/mysql stop
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd stop
fi




echo "Stop LTNMP..."
/etc/init.d/nginx start
/etc/init.d/mysql start
/etc/init.d/php-fpm start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi


echo "Stop  add Starting PHP $php_version PHP-FPM..."
/etc/init.d/php-fpm$ver1 stop
/etc/init.d/php-fpm$ver1 start



cd $cur_dir
cp vhost.sh /root/addvhost.sh
chmod +x /root/addvhost.sh

clear


if [ -s /usr/local/php$ver1/sbin/php-fpm ] && [ -s /usr/local/php$ver1/etc/php.ini ] && [ -s /usr/local/php$ver1/bin/php ]; then

printf "===================== install PHP5.* completed ===================\n"
printf "Install PHP5.*  completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install PHP5.* for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install PHP5.*  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"

else
echo "Failed to install PHP $php_version!,you need try to run ./phpver.sh 2>&1 | tee install phpver.log to record install logs."
fi

echo ""
/usr/local/php$ver1/bin/php  -v
echo ""