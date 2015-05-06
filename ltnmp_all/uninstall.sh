#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Uninstall LTNMP,  Written by PHP360"
echo "========================================================================="
echo "A tool to uninstall Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http:/www.05gzs.com/"
echo ""
echo "Please backup your mysql data and configure files first!!!!!"
echo ""
echo "========================================================================="

echo ""
	uninstall=""
	echo "INPUT 1 to uninstall LTNMP"
	echo "INPUT 2 to uninstall LTANMP"
	read -p "(Please input 1 or 2):" uninstall

	case "$uninstall" in
	1)
	echo "You will uninstall LTNMP"
	echo "Please backup your configure files and mysql data!!!!!!"
	echo "The following directory or files will be remove!"
	cat << EOF
/usr/local/php
/usr/local/nginx
/usr/local/mysql
/usr/local/zend
/etc/my.cnf
/root/vhost.sh
/root/ltnmp
/root/run.sh
/etc/init.d/php-fpm
/etc/init.d/nginx
/etc/init.d/mysql
EOF
	;;
	2)
	echo "You will uninstall LTANMP"
	echo "Please backup your configure files and mysql data!!!!!!"
	echo "The following directory or files will be remove!"
	cat << EOF
/usr/local/php
/usr/local/nginx
/usr/local/mysql
/usr/local/zend
/usr/local/apache
/etc/my.cnf
/root/vhost.sh
/root/ltanmp
/root/run.sh
/etc/init.d/php-fpm
/etc/init.d/nginx
/etc/init.d/mysql
/etc/init.d/httpd
EOF
	esac

echo "Please backup your configure files and mysql data!!!!!!"

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
	echo "Press any key to start uninstall LTANMP , please wait ......"
	char=`get_char`

function uninstall_ltnmp
{
	/etc/init.d/nginx stop
	/etc/init.d/mysql stop
	/etc/init.d/php-fpm stop

	rm -rf /usr/local/php
	rm -rf /usr/local/nginx
	rm -rf /usr/local/mysql
	rm -rf /usr/local/zend

	rm -f /etc/my.cnf
	rm -f /root/vhost.sh
	rm -f /root/ltnmp
	rm -f /root/run.sh
	rm -f /etc/init.d/php-fpm
	rm -f /etc/init.d/nginx
	rm -f /etc/init.d/mysql
	echo "LTNMP Uninstall completed."
}

function uninstall_ltanmp
{
	/etc/init.d/nginx stop
	/etc/init.d/mysql stop
	/etc/init.d/php-fpm stop

	rm -rf /usr/local/php
	rm -rf /usr/local/nginx
	rm -rf /usr/local/mysql
	rm -rf /usr/local/zend
	rm -rf /usr/local/apache

	rm -f /etc/my.cnf
	rm -f /root/vhost.sh
	rm -f /root/ltanmp
	rm -f /root/run.sh
	rm -f /etc/init.d/php-fpm
	rm -f /etc/init.d/nginx
	rm -f /etc/init.d/mysql
	rm -f /etc/init.d/httpd
	echo "LTANMP Uninstall completed."
}

if [ "$uninstall" = "1" ]; then
	uninstall_ltnmp
else
	uninstall_ltanmp
fi

echo "========================================================================="
echo "LTNMP for CentOS/RadHat Linux VPS  Written by PHP360 "
echo "========================================================================="
echo "A tool to uninstall Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="