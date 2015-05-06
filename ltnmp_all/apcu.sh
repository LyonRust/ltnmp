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
printf "Install APCU for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install APCU  for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com  \n"
printf "=======================================================================\n"

cur_dir=$(pwd)


	ver="1"
	ver0="Install"

	echo "Which version do you want to install:"
	echo "Install APCu                  please type: 1"
	echo "Delete  APCu                  please type: 0"
	echo ""
	read -p "Type 1 or 0 (Default:1):" ver
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

		echo "You will Delete APCu !!"
		ver0="Delete"
	fi




#-----------set APCu ver

if [ "$ver" = 1 ] ; then

	apcu_versiona="4.0.1"
	echo "Please input APCu ver(You can get APCu version number from http://pecl.php.net/package/APCu)"
	read -p "(Default APCu ver: $apcu_versiona):" apcu_version
	if [ "$apcu_version" = "" ]; then
		apcu_version=$apcu_versiona
	fi
	echo "==========================="
	echo "APCu_ver = $apcu_version"
	echo "==========================="


	if echo $apcu_version | grep -q "4.0.*";then
	echo "You will install APCu !!"
	else
	echo "DO NOT SUPPORT APCu VERSION :$apcu_version ,  Do not APCu VER"
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





#-----------Delete APCu

if [ "$ver" = "0" ]; then

apcuv=`grep "apcu.so" /usr/local/php/etc/php.ini`

if echo $apcuv | grep -q "apcu.so*";then
sed -i '/extension = "apcu.so"/d' /usr/local/php/etc/php.ini

/etc/init.d/php-fpm stop
/etc/init.d/php-fpm start

  else

	echo "PHP Ver  Not found  APCu !"
	exit 1
fi

	echo "Delete APCu  completed !!"
	echo ""
	exit 1
fi




#-----------php 5.5 EXIT    Zend 3.3  EXIT

phpv=`/usr/local/php/bin/php -v`

if echo $phpv | grep -q "Zend Optimizer v3.3.9";then

	echo "APCu And  Zend Optimizer v3.3.9   Together Can't install !"
	exit 1
fi


if echo $phpv | grep -q "PHP 5.5.*";then

echo "DO NOT SUPPORT APCu VERSION :$apcu_version , Can not installed in php5.5"
echo "Waiting for script to EXIT......"
exit 1
fi




#-----------Down APCu

if [ -s APCu-$apcu_version.tgz ]; then
  echo "APCu-$apcu_version.tgz [found]"
  else
  echo "APCu-$apcu_version.tgz not found!!!download now......"
  wget -c http://pecl.php.net/get/apcu-$apcu_version.tgz

  if [ $? -eq 0 ]; then
	echo "Download apcu-$apcu_version.tar.gz successfully!"
  else
	echo "WARNING!May be the APCu version you input was wrong,please check!"
	echo "APCu Version input was:"$apcu_version
	echo ""
	echo "You can get version number from http://pecl.php.net/package/APCu"
	echo ""
	exit 1
  fi

fi







#-----------Install APCu

rm -rf apcu-$apcu_version
tar xzvf apcu-$apcu_version.tgz
cd apcu-$apcu_version
/usr/bin/phpize
./configure --enable-apcu --with-php-config=/usr/local/php/bin/php-config
make && make install


sed -ni '1,/;eaccelerator/p;/;ionCube/,$ p' /usr/local/php/etc/php.ini
sed -i '/extension = "apcu.so"/d' /usr/local/php/etc/php.ini
sed -i '/;eaccelerator/i extension = "apcu.so"' /usr/local/php/etc/php.ini



if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi


clear

printf "===================== install APCU completed ===================\n"
printf "Install APCu  completed,enjoy it!\n"
printf "=======================================================================\n"
printf "Install APCu for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install APCu for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com   \n"
printf "=======================================================================\n"