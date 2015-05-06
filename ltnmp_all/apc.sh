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
printf "Install APC for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install APC  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com  \n"
printf "=======================================================================\n"
cur_dir=$(pwd)


	ver="1"
	ver0="Install"

	echo "Which version do you want to install:"
	echo "Install APC                  please type: 1"
	echo "Delete  APC                  please type: 0"
	echo ""
	read -p "Type 1 or 0 (Default: 1):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="1"
	fi


	if [ "$ver" != 1 ] && [ "$ver" != 0 ] ; then
        echo ""
	echo "Error: You must input  1 or  0!!"
	exit 1
	fi



	if [ "$ver" = "0" ]; then

		echo "You will Delete APC !!"
		ver0="Delete"
	fi




#-----------set APC ver

if [ "$ver" = 1 ] ; then

	apc_versiona="3.1.13"
	echo "Please input APC ver(You can get APC version number from http://pecl.php.net/package/APC)"
	read -p "(Default APC ver: $apc_versiona):" apc_version
	if [ "$apc_version" = "" ]; then
		apc_version=$apc_versiona
	fi
	echo "==========================="
	echo "APC_ver = $apc_version"
	echo "==========================="


	if echo $apc_version | grep -q "3.1.*";then
	echo "You will install APC !!"
	else
	echo "DO NOT SUPPORT APC VERSION :$apc_version ,  Do not APC VER"
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
	echo "Press any key to start $ver0 ...or Press Ctrl+c to cancel"
	char=`get_char`





#-----------Delete APC

if [ "$ver" = "0" ]; then

apcv=`grep "apc.so" /usr/local/php/etc/php.ini`

if echo $apcv | grep -q "apc.so*";then
sed -i '/extension = "apc.so"/d' /usr/local/php/etc/php.ini

/etc/init.d/php-fpm stop
/etc/init.d/php-fpm start

  else

	echo "PHP Ver  Not found  APC !"
	exit 1
fi

	echo "Delete APC  completed !!"
	echo ""
	exit 1
fi




#-----------php 5.5 EXIT    Zend 3.3  EXIT

phpv=`/usr/local/php/bin/php -v`

if echo $phpv | grep -q "Zend Optimizer v3.3.9";then

	echo "APC And  Zend Optimizer v3.3.9   Together Can't install !"
	exit 1
fi


if echo $phpv | grep -q "PHP 5.5.*";then

echo "DO NOT SUPPORT APC VERSION :$apc_version , Can not installed in php5.5"
echo "Waiting for script to EXIT......"
exit 1
fi




#-----------Down APC

if [ -s APC-$apc_version.tgz ]; then
  echo "APC-$apc_version.tgz [found]"
  else
  echo "APC-$apc_version.tgz not found!!!download now......"
  wget -c http://pecl.php.net/get/APC-$apc_version.tgz

  if [ $? -eq 0 ]; then
	echo "Download APC-$apc_version.tar.gz successfully!"
  else
	echo "WARNING!May be the APC version you input was wrong,please check!"
	echo "APC Version input was:"$apc_version
	echo ""
	echo "You can get version number from http://pecl.php.net/package/APC"
	echo ""
	exit 1
  fi

fi







#-----------Install APC

rm -rf APC-$apc_version
tar xzvf APC-$apc_version.tgz
cd APC-$apc_version
/usr/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --enable-apc --enable-mmap --enable-apc-spinlocks --disable-apc-pthreadmutex
make && make install


sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini
sed -i '/extension = "apc.so"/d' /usr/local/php/etc/php.ini
sed -i '/;eaccelerator/i extension = "apc.so"' /usr/local/php/etc/php.ini



if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

printf "===================== install APC completed ===================\n"
printf "Install APC  completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install APC for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install APC  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com   \n"
printf "=======================================================================\n"
