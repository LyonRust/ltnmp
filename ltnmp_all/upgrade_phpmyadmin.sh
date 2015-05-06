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
echo "Upgrade phpMyAdmin for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
cur_dir=$(pwd)

version=""
echo "Please input phpMyAdmin version you want:"
echo "You can get version number from http://www.phpmyadmin.net/home_page/downloads.php"
read -p "(example: 3.4.9 ):" version
if [ "$version" = "" ]; then
	echo "Error: You must input phpMyAdmin version!!"
	exit 1
fi
echo "==========================="

echo "You want to upgrade phpMyAdmin version to $version"

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
wget -c http://jaist.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/$version/phpMyAdmin-$version-all-languages.tar.gz

if [ -s phpMyAdmin-$version-all-languages.tar.gz ]; then
  echo "phpMyAdmin-$version-all-languages.tar.gz [found]"
  else
  echo "Error: phpMyAdmin-$version-all-languages.tar.gz not found!!!download now......"
  wget -c http://nchc.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/$version/phpMyAdmin-$version-all-languages.tar.gz
  dl_status=`echo $?`
  if [ $dl_status = "0" ]; then
	echo "Download phpMyAdmin-$version-all-languages.tar.gz successfully!"
  else
	echo "WARNING!May be the phpMyAdmin version you input was wrong,please check!"
	echo "phpMyAdmin Version input was:"$version
	exit 1
  fi
fi
rm -rf /home/www/default/phpmyadmin/
tar zxvf phpMyAdmin-$version-all-languages.tar.gz
mv phpMyAdmin-$version-all-languages /home/www/default/phpmyadmin/
cp conf/config.inc.php /home/www/default/phpmyadmin/config.inc.php
sed -i 's/PHP360/php360'$RANDOM'05gzs.com/g' /home/www/default/phpmyadmin/config.inc.php
mkdir /home/www/default/phpmyadmin/upload/
mkdir /home/www/default/phpmyadmin/save/
chmod 755 -R /home/www/default/phpmyadmin/
chown www:www -R /home/www/default/phpmyadmin/

cd $cur_dir

echo "========================================================================="
echo "You have successfully upgrade from phpMyAdmin-$version-all-languages"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="