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
echo "Install ImageMagick for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzd.com/"
echo "========================================================================="

if [ "$1" != "--help" ]; then

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
if [ -s ImageMagick-7.0.0-0.tar.gz ]; then
  echo "ImageMagick-7.0.0-0.tar.gz [found]"
  else
  echo "Error: ImageMagick-7.0.0-0.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ImageMagick-7.0.0-0.tar.gz
  #wget -c http://ltanmp.googlecode.com/files/ImageMagick-7.0.0-0.tar.gz
  if [ $? -eq 0 ]; then
	echo "Download ImageMagick-7.0.0-0.tar.gz successfully!"
  else
	echo "WARNING! ImageMagick-7.0.0-0.tar.gz was not download!"
	sleep 5
	exit 1
  fi
fi

if [ -s imagick-3.1.0RC2.tgz ]; then
  echo "imagick-3.1.0RC2.tgz [found]"
  else
  echo "Error: imagick-3.1.0RC2.tgz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/imagick-3.1.0RC2.tgz
  if [ $? -eq 0 ]; then
	echo "Download imagick-3.1.0RC2.tgz successfully!"
  else
	echo "WARNING! imagick-3.1.0RC2.tgz was not download!"
	sleep 5
	exit 1
  fi
fi
echo "========================Install ImageMagick=============================="
tar zxvf ImageMagick-7.0.0-0.tar.gz
cd ImageMagick-7.0.0-0/
./configure --prefix=/usr/local/imagemagick
make && make install
cd ../

tar zxvf imagick-3.1.0RC2.tgz
cd imagick-3.1.0RC2/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
make && make install
cd ../

sed -i '/extension = "pdo_mysql.so"/i\
extension = "imagick.so"' /usr/local/php/etc/php.ini

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi

echo "========================================================================="
echo "You have successfully install ImageMagick                                "
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzd.com/"
echo ""
echo "========================================================================="
fi


