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
printf "Install xcache for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install xcache for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"
cur_dir=$(pwd)

	ver="1"
	ver0="Install"

	echo "Which version do you want to install:"
	echo "Install XCache      	please type: 1"
	echo "Delete  XCache      	please type: 0"
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

		echo "You will Delete XCache !!"
		ver0="Delete"
	fi




#-----------set XCache ver

if [ "$ver" = 1 ] ; then

	xcache_versiona="3.0.3"
	echo "Please input XCache ver(You can get version number from http://xcache.lighttpd.net/)"
	read -p "(Default XCache ver: $xcache_versiona):" xcache_version
	if [ "$xcache_version" = "" ]; then
		xcache_version=$xcache_versiona
	fi
	echo "==========================="
	echo "XCache_ver = $xcache_version"
	echo "==========================="
	echo ""


	memorya="32"
	echo "Please input XCache in memory:"
	read -p "( Default in memory: $memorya ):" memory
	if [ "$memory" = "" ]; then
		memory=$memorya
	fi
	echo "==========================="
	echo "XCache in memory = '$memory'M"
	echo "==========================="



	cpu_count=`cat /proc/cpuinfo |grep -c processor`
	if [ "$cpu_count" = "" ] ; then
	cpu_count="1";
	fi



	if echo $xcache_version | grep -q "2.0.*"||echo $xcache_version | grep -q "3.0.*"||echo $xcache_version | grep -q "3.1.*";then
	echo "You will install XCache !!"
	else
	echo "DO NOT SUPPORT XCache VERSION :$xcache_version ,  Do not XCache VER"
	echo "Waiting for script to EXIT......"
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
	echo "Press any key to start  "$ver0"  ...or Press Ctrl+c to cancel !"
	char=`get_char`






#-----------Delete XCache

if [ "$ver" = "0" ]; then

/etc/init.d/php-fpm stop
phpv=`/usr/local/php/bin/php -v`
xcav=`grep "xcache" /usr/local/php/etc/php.ini`

  if echo $phpv | grep -q "XCache" || echo $xcav | grep -q "xcache*";then

sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

/etc/init.d/php-fpm start

  else
	echo "PHP Ver  Not found  XCache !!"
	exit 1
  fi

	echo "Delete XCache  completed !!"
	echo ""
	/usr/local/php/bin/php -v
	echo ""
	exit 1
fi




#-----------php ver

phpv=`/usr/local/php/bin/php -v`

if echo $phpv | grep -q "PHP 5.2.*";then
xcapath="/usr/local/php54/lib/php/extensions/no-debug-non-zts-20060613/xcache.so"
rm -f /usr/local/php54/lib/php/extensions/no-debug-non-zts-20060613/xcache.so
  else
if echo $phpv | grep -q "PHP 5.3.*";then
xcapath="/usr/local/php54/lib/php/extensions/no-debug-non-zts-20090626/xcache.so"
rm -f /usr/local/php54/lib/php/extensions/no-debug-non-zts-20090626/xcache.so
  else
if echo $phpv | grep -q "PHP 5.4.*";then
xcapath="/usr/local/php54/lib/php/extensions/no-debug-non-zts-20100525/xcache.so"
rm -f /usr/local/php54/lib/php/extensions/no-debug-non-zts-20100525/xcache.so
  else
if echo $phpv | grep -q "PHP 5.5.*";then
xcapath="/usr/local/php54/lib/php/extensions/no-debug-non-zts-20121212/xcache.so"
rm -f /usr/local/php54/lib/php/extensions/no-debug-non-zts-20121212/xcache.so
  else
	echo "PHP Ver Error Can't install  XCache !!"
	exit 1
fi
fi
fi
fi






#-----------php 5.5 EXIT

if echo $phpv | grep -q "PHP 5.5.*";then
echo ""
echo "DO NOT SUPPORT XCache VERSION :$xcache_version , Can not installed in php5.5"
echo "Waiting for script to EXIT......"
exit 1
fi



#-----------Down XCache

if [ -s xcache-$xcache_version.tar.gz ]; then
  echo "xcache-$xcache_version.tar.gz [found]"
  else
  echo "xcache-$xcache_version.tar.gz not found!!!download now......"
wget http://xcache.lighttpd.net/pub/Releases/$xcache_version/xcache-$xcache_version.tar.gz

  if [ $? -eq 0 ]; then
	echo "Download xcache-$xcache_version.tar.gz successfully!"
  else
	echo "WARNING!May be the XCache version you input was wrong,please check!"
	echo "XCache Version input was:"$xcache_version
	echo ""
	echo "You can get version number from http://xcache.lighttpd.net/"
	echo ""
	exit 1
  fi

fi






#-----------Install XCache-3.0.*

if echo $xcache_version | grep -q "3.0.*";then

rm -rf xcache-$xcache_version
tar xvzf xcache-$xcache_version.tar.gz
cd xcache-$xcache_version
phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-xcache --enable-xcache-optimizer
make && make install
cd ../


cat >xcache.ini<<EOF
[xcache-common]
extension = xcache.so

[xcache]
xcache.shm_scheme =        "mmap"
xcache.size  =              '$memory'M
xcache.count =                $cpu_count
xcache.slots =                8K
xcache.ttl   =                 0
xcache.gc_interval =           0
xcache.var_size  =            4M
xcache.var_count =             1
xcache.var_slots =            8K
xcache.var_ttl   =             0
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
xcache.var_namespace_mode =    0
xcache.var_namespace =        ""
xcache.readonly_protection = Off
xcache.mmap_path =    "/tmp/xcache"
xcache.coredump_directory =   ""
xcache.disable_on_crash =    Off
xcache.experimental =        Off
xcache.cacher =               On
xcache.stat   =               On
xcache.optimizer =           Off

[xcache.coverager]
xcache.coverager =           Off
xcache.coverager_autostart =  On
xcache.coveragedump_directory = ""

EOF




  else
#-----------Install XCache-2.0.*

rm -f xcache-$xcache_version
tar xvzf xcache-$xcache_version.tar.gz
cd xcache-$xcache_version
phpize
./configure  --enable-xcache --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../


cat >xcache.ini<<EOF
[xcache-common]
zend_extension = $xcapath

[xcache]
xcache.size = '$memory'M
xcache.shm_scheme = "mmap"
xcache.count = $cpu_count
xcache.slots = 8K
xcache.ttl = 0
xcache.gc_interval = 0
xcache.var_size = 8M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 0
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.test = Off
xcache.readonly_protection = On
xcache.mmap_path = "/tmp/xcache"
xcache.coredump_directory = ""
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off
[xcache.coverager]
xcache.coverager = On
xcache.coveragedump_directory = ""

EOF


fi
#-----------Install END



sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini
sed -i '/extension = "apc.so"/d' /usr/local/php/etc/php.ini


sed -i '/;eaccelerator/ {
r xcache.ini
}' /usr/local/php/etc/php.ini

rm xcache.ini



if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

printf "===================== install XCache completed ===================\n"
printf "Install xcache  completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install xcache for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install xcache  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"