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
echo " Remove php disable functions for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="

cur_dir=$(pwd)


	ver="1"
	ver0="On"
	echo "Which version do you want to install:"
	echo "disable_functions On       please type: 1"
	echo "disable_functions Off     please type: 2"
	echo "open_basedir on      please type: 3"
	echo "open_basedir 0ff      please type: 4"
	echo "scandir      please type: 5"
	echo "exec      please type: 6"
	read -p "Type 1 or 2 or 3 or 4 or 5 or 6 (Default version 1):" ver

	if [ "$ver" = "" ]; then
		ver="1"
	fi


	if [ "$ver" != 1 ] && [ "$ver" != 2 ] && [ "$ver" != 3 ] && [ "$ver" != 4 ] && [ "$ver" != 5 ] && [ "$ver" != 6 ]; then
        echo ""
	echo "Error: You must input  1 or 2 or 3 or 4 or 5 or 6 !!"
	exit 1
	fi


	if [ "$ver" = 3 ]; then
		ver0="Off"
else
         ver0="On"
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
	echo "Press any key PHP disable_functions "$ver0" ...or Press Ctrl+c to cancel"

char=`get_char`


#Backup old php.ini files
echo ""
echo "Backup old php.ini files to /root ......"
echo ""
cp /usr/local/php/etc/php.ini  /root/php.ini.old.bak

if [ "$ver" = "1" ]; then
echo "disable_functions On  to php.ini  file......"
sed -i 's/;disable_functions/disable_functions/g' /usr/local/php/etc/php.ini
fi

if [ "$ver" = "2" ]; then
echo "disable_functions Off  to php.ini  file......"
sed -i 's/disable_functions/;disable_functions/g' /usr/local/php/etc/php.ini
fi

if [ "$ver" = "3" ]; then
echo "open_basedir On  to php.ini  file......"
sed -i 's#;open_basedir =#open_basedir = ../:/tmp/:/etc/:/var/www:/tmp/:/var/tmp/:/proc/#g' /usr/local/php/etc/php.ini
fi

if [ "$ver" = "4" ]; then
echo "open_basedir Off  to php.ini  file......"
sed -i 's#open_basedir = ../:/tmp/:/etc/:/var/www:/tmp/:/var/tmp/:/proc/#;open_basedir =#g' /usr/local/php/etc/php.ini
fi

if [ "$ver" = "5" ]; then
echo "scandir Off  to php.ini  file......"
sed -i 's/,scandir//g' /usr/local/php/etc/php.ini
fi

if [ "$ver" = "6" ]; then
echo "exec  to php.ini  file......"
sed -i 's/,exec//g' /usr/local/php/etc/php.ini
fi

if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "Restarting Apache......"
/etc/init.d/httpd -k restart
else
echo "Restarting php-fpm......"
/etc/init.d/php-fpm restart
fi
echo ""
printf "=============== PHP disable_functions "$ver0" completed ================\n"
echo "Install PHPtools  completed,enjoy it!"
echo "========================================================================="
echo "Install PHPtools for LTNMP  ,  Written by php360"
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux"
echo "For more information please visit http://www.05gzs.com"
echo "========================================================================="