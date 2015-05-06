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
echo "Upgrade Nginx for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="

nv=`/usr/local/nginx/sbin/nginx -v 2>&1`
old_nginx_version=`echo $nv | cut -c22-`
#echo $old_nginx_version

if [ "$1" != "--help" ]; then

#set nginx version

	nginx_version=""
	echo "Current Nginx Version:$old_nginx_version"
	echo "Please input nginx version you want:"
	echo "You can get version number from http://nginx.org/en/download.html"
	read -p "(example: 0.8.54 ):" nginx_version
	if [ "$nginx_version" = "" ]; then
		echo "Error: You must input nginx version!!"
		exit 1
	fi
	echo "==========================="

	echo "You want to upgrade nginx version to $nginx_version"

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
if [ -s nginx-$nginx_version.tar.gz ]; then
  echo "nginx-$nginx_version.tar.gz [found]"
  else
  echo "Error: nginx-$nginx_version.tar.gz not found!!!download now......"
  wget -c http://nginx.org/download/nginx-$nginx_version.tar.gz
  if [ $? -eq 0 ]; then
	echo "Download nginx-$nginx_version.tar.gz successfully!"
  else
	echo "WARNING!May be the nginx version you input was wrong,please check!"
	echo "Nginx Version input was:"$nginx_version
	sleep 5
	exit 1
  fi
fi
echo "============================check files=================================="
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

rm -rf nginx-$nginx_version/

tar zxvf nginx-$nginx_version.tar.gz
cd nginx-$nginx_version/
/usr/local/nginx/sbin/nginx -V &> $$
nginx_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
rm -rf $$
./configure $nginx_configure_arguments
make && make install

mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old
cp objs/nginx /usr/local/nginx/sbin/nginx
/usr/local/nginx/sbin/nginx -t
make upgrade
echo "Upgrade completed!"
echo "Program will display Nginx Version......"
/usr/local/nginx/sbin/nginx -v
cd ../

echo "Restarting Nginx..."
/etc/init.d/nginx restart

echo "Starting MySQL..."
/etc/init.d/mysql start
echo "Starting PHP-FPM..."
/etc/init.d/php-fpm start
if [ -s /etc/init.d/memceached ]; then
  echo "Starting Memcached..."
  /etc/init.d/memcacehd start
fi

echo "========================================================================="
echo "You have successfully upgrade from $old_nginx_version to $nginx_version"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="
fi
