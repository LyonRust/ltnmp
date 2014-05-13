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
printf "Install Zend Opcache for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install xcache for ltanmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"
echo ""
echo "ZendOpcache version number from http://pecl.php.net/package/ZendOpcache/"
echo ""
cur_dir=$(pwd)

	ver="1"
	ver0="Install"

	echo "Which version do you want to install:"
	echo "Install ZendOpcache      	please type: 1"
	echo "Delete  ZendOpcache      	please type: 0"
	echo ""
	read -p "Type 1 or 0 (Default:1):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="1"
	fi

	if [ "$ver" != 1 ] && [ "$ver" != 0 ]; then
	echo "Error: You must input  1 or 0!!"
	exit 1
	fi

	if [ "$ver" = "0" ]; then

		echo "You will Delete ZendOpcache !!"
		ver0="Delete"
	fi

#-----------set ZendOpcache ver

if [ "$ver" = 1 ] ; then

	zendopcache_versiona="7.0.2"
	echo "Please input ZendOpcache ver:"
	read -p "( Default ZendOpcache ver: $zendopcache_versiona ):" zendopcache_version
	if [ "$zendopcache_version" = "" ]; then
		zendopcache_version=$zendopcache_versiona
	fi
	echo "==========================="
	echo "ZendOpcache_ver = $zendopcache_version"
	echo "==========================="


	if echo $zendopcache_version | grep -q "7.0.*"||echo $zendopcache_version | grep -q "7.1.*"||echo $zendopcache_version | grep -q "7.2.*";then
	verver=""
	else
	echo "DO NOT SUPPORT ZendOpcache VERSION :$zendopcache_version ,  Do not ZendOpcache VER"
	echo "Waiting for script to EXIT......"
	exit 1
	fi

	memorya="64"
	echo "Please input ZendOpcache in memory:"
	read -p "( Default in memory: $memorya ):" memory
	if [ "$memory" = "" ]; then
		memory=$memorya
	fi
	echo "==========================="
	echo "ZendOpcache in memory = $memory"
	echo "==========================="

	timeouta="180"
	echo "Please input ZendOpcache cache timeout:"
	read -p "( Default cache timeout: $timeouta ):" timeout
	if [ "$timeout" = "" ]; then
		timeout=$timeouta
	fi
	echo "==========================="
	echo "ZendOpcache cache timeout = $timeout"
	echo "==========================="

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
	echo "Press any key to start  "$ver0"  ...or Press Ctrl+c to cancel !"
	char=`get_char`

#-----------Delete ZendOpcache

if [ "$ver" = "0" ]; then

/etc/init.d/php-fpm stop
phpv=`/usr/local/php/bin/php -v`
xcav=`grep "zendopcache" /usr/local/php/etc/php.ini`

  if echo $phpv | grep -q "ZendOpcache" || echo $xcav | grep -q "zendopcache*";then

sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

/etc/init.d/php-fpm start

  else
	echo "PHP Ver  Not found  ZendOpcache !!"
	exit 1
  fi

	echo "Delete ZendOpcache  completed !!"
	echo ""
	/usr/local/php/bin/php -v
	echo ""
	exit 1
fi

#-----------php ver

phpv=`/usr/local/php/bin/php -v`

if echo $phpv | grep -q "PHP 5.2.*";then
zendopcachepath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/opcache.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/opcache.so
  else
if echo $phpv | grep -q "PHP 5.3.*";then
zendopcachepath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/opcache.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/opcache.so
  else
if echo $phpv | grep -q "PHP 5.4.*";then
zendopcachepath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/opcache.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/opcache.so
  else
if echo $phpv | grep -q "PHP 5.5.*";then
zendopcachepath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/opcache.so
  else
	echo "PHP Ver Error Can't install  ZendOpcache !!"
	exit 1
fi
fi
fi
fi

#-----------php 5.6 EXIT

if echo $phpv | grep -q "PHP 5.6.*";then
echo ""
echo "DO NOT SUPPORT ZendOpcache VERSION :$zendopcache_version , Can not installed in php5.5"
echo "Waiting for script to EXIT......"
exit 1
fi

#-----------Down ZendOpcache

if [ -s zendopcache-$zendopcache_version.tgz ]; then
  echo "zendopcache-$zendopcache_version.tgz [found]"
  else
  echo "zendopcache-$zendopcache_version.tgz not found!!!download now......"
wget http://pecl.php.net/get/zendopcache-$zendopcache_version.tgz

  if [ $? -eq 0 ]; then
	echo "Download zendopcache-$zendopcache_version.tgz successfully!"
  else
	echo "WARNING!May be the ZendOpcache version you input was wrong,please check!"
	echo "ZendOpcache Version input was:"$zendopcache_version
	echo ""
	echo "You can get version number from http://pecl.php.net/package/ZendOpcache/"
	echo ""
	exit 1
  fi

fi

#-----------Install ZendOpcache-7.*.*

if echo $zendopcache_version | grep -q "7.0.*";then

rm -rf zendopcache-$zendopcache_version
tar xvzf zendopcache-$zendopcache_version.tgz
cd zendopcache-$zendopcache_version
phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

cat >zendopcache.ini<<EOF
;ZendOpcache
[Zend Opcache]
zend_extension= $zendopcachepath
opcache.memory_consumption=$memory
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.force_restart_timeout=$timeout
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;ZendOpcache end

EOF


  else
	echo "DO NOT SUPPORT ZendOpcache VERSION :$zendopcache_version ,  Do not ZendOpcache VER"
	echo "Waiting for script to EXIT......"
	exit 1
fi

#-----------Install END

sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

sed -i '/;eaccelerator/ {
r zendopcache.ini
}' /usr/local/php/etc/php.ini

rm -rf zendopcache.ini

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

printf "===================== install Zend Opcache completed ===================\n"
printf "Install Zend Opcache  completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install Zend Opcache for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install xcache  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"