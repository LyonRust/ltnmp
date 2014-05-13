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
printf "Install eAcesselerator for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install eAccelerator for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"

cur_dir=$(pwd)

	ver="3"
	ver0="Install"
	ver1="1.0"
	echo "Which version do you want to install:"
	echo "Install eAccelerator 0.9.5.3 (PHP 5.2)            please type: 1"
	echo "Install eAccelerator 0.9.6.1 (PHP 5.2/5.3)		please type: 2"
	echo "Install eAccelerator 1.0     (PHP 5.2/5.3/5.4)	please type: 3"
	echo "Delete  eAccelerator                              please type: 0"
	echo ""
	read -p "Type 1 or 2 or 3 or 0 (Default version 3):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="3"
	fi


	if [ "$ver" != 1 ] && [ "$ver" != 2 ] && [ "$ver" != 3 ] && [ "$ver" != 0 ]; then
        echo ""
	echo "Error: You must input  1 or 2 or 3 or 0!!"
	exit 1
	fi



	if [ "$ver" = "1" ]; then
		echo "You will install eAccelerator 0.9.5.3"
        ver1="0.9.5.3"
else
	if [ "$ver" = "2" ]; then
		echo "You will install eAccelerator 0.9.6.1"
        ver1="0.9.6.1"
else
	if [ "$ver" = "3" ]; then
		echo "You will install eAccelerator 1.0"
        ver1="1.0"

else
	if [ "$ver" = "0" ]; then
		echo "You will Delete eAccelerator !"
		ver0="Delete"
fi
fi
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
	echo "Press any key to start $ver0  ...or Press Ctrl+c to cancel"
	char=`get_char`




#-----------Delete eAccelerator

if [ "$ver" = "0" ]; then

/etc/init.d/php-fpm stop
phpv=`/usr/local/php/bin/php -v`
if echo $phpv | grep -q "eAccelerator";then

sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini

/etc/init.d/php-fpm start

  else
	echo "PHP Ver  Not found  eAccelerator !!"
	exit 1
fi
	echo "Delete eAccelerator  completed !!"
	echo ""
	/usr/local/php/bin/php -v
	echo ""
	exit 1
fi





#-----------php ver

phpv=`/usr/local/php/bin/php -v`

if echo $phpv | grep -q "PHP 5.2.*";then
eapath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so
  else
if echo $phpv | grep -q "PHP 5.3.*";then
eapath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so
  else
if echo $phpv | grep -q "PHP 5.4.*";then
eapath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/eaccelerator.so
  else
if echo $phpv | grep -q "PHP 5.5.*";then
xcapath="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so"
rm -f /usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/eaccelerator.so
  else
	echo "PHP Ver Error Can't install  eAccelerator !"
	exit 1
fi
fi
fi
fi






#-----------php 5.5 EXIT

if echo $phpv | grep -q "PHP 5.5.*";then
echo ""
echo "DO NOT SUPPORT eAccelerator VERSION : $ver1 , Can not installed in php5.5"
echo "Waiting for script to EXIT......"
exit 1
fi





#-----------Install eAccelerator 0.9.5.3

if [ "$ver" = "1" ]; then

if echo $phpv | grep -q "PHP 5.3.*";then
	echo "PHP 5.3.* Can't install eAccelerator 0.9.5.3!"
	exit 1
else
if echo $phpv | grep -q "PHP 5.4.*";then
	echo "PHP 5.4.* Can't install eAccelerator 0.9.5.3!"
	exit 1
fi
fi


if [ -s eaccelerator-0.9.5.3.tar.bz2 ]; then
  echo "eaccelerator-0.9.5.3.tar.bz2 [found]"
  else
  echo "eaccelerator-0.9.5.3.tar.bz2 not found!!!download now......"
wget -c http://www.05gzs.com/ltnmp/eaccelerator-0.9.5.3.tar.bz2
fi

rm -rf eaccelerator-0.9.5.3
tar jxvf eaccelerator-0.9.5.3.tar.bz2
cd eaccelerator-0.9.5.3/
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config --with-eaccelerator-shared-memory
make && make install
cd ../

fi







#-----------Install eAccelerator 0.9.6.1

if [ "$ver" = "2" ]; then

if echo $phpv | grep -q "PHP 5.4.*";then
	echo "PHP 5.4.* Can't install eAccelerator 0.9.6.1!"
	exit 1
fi

if [ -s eaccelerator-0.9.6.1.tar.bz2 ]; then
  echo "eaccelerator-0.9.6.1.tar.bz2 [found]"
  else
  echo "eaccelerator-0.9.6.1.tar.bz2 not found!!!download now......"
wget -c http://www.05gzs.com/ltnmp/eaccelerator-0.9.6.1.tar.bz2
fi

rm -f eaccelerator-0.9.6.1
tar jxvf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1/
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config --with-eaccelerator-shared-memory
make && make install
cd ../

fi






#-----------Install eAccelerator 1.0

if [ "$ver" = "3" ]; then

if [ -s eaccelerator-eaccelerator-42067ac.tar.gz ]; then
  echo "eaccelerator-eaccelerator-42067ac.tar.gz [found]"
  else
  echo "eaccelerator-eaccelerator-42067ac.tar.gz not found!!!download now......"
wget -c http://www.05gzs.com/ltnmp/eaccelerator-eaccelerator-42067ac.tar.gz
fi

rm -f eaccelerator-eaccelerator-42067ac
tar -zxvf eaccelerator-eaccelerator-42067ac.tar.gz
cd eaccelerator-eaccelerator-42067ac
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

fi



sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini
sed -i '/extension = "apc.so"/d' /usr/local/php/etc/php.ini

cat >ca.ini<<EOF

[eaccelerator]
zend_extension="$eapath"
eaccelerator.shm_size="1"
eaccelerator.cache_dir="/tmp/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="3600"
eaccelerator.shm_prune_period="3600"
eaccelerator.shm_only="0"
eaccelerator.compress="1"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"
EOF

sed -i '/;eaccelerator/ {
r ca.ini
}' /usr/local/php/etc/php.ini
rm ca.ini




if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

printf "===================== install $ver0 completed ==========\n"
printf "Install $ver0 completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install eAcesselerator for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install $ver0  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"
