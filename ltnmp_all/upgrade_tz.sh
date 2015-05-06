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
echo "Upgrade p.php for LTNMP,  Written by php360"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
cur_dir=$(pwd)

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

rm -rf /home/www/default/p.php
if [ -s p.tar.gz ]; then
	echo "p.tar.gz [found]"
else
	echo "p.tar.gz not found,download it......"
	wget -c http://www.05gzs.com/ltnmp/p.tar.gz
fi
#wget -c http://ltanmp.googlecode.com/files/p.tar.gz
tar zxvf p.tar.gz
cp p.php /home/www/default/p.php
rm -rf p.tar.gz

cd $cur_dir

echo "========================================================================="
echo "You have successfully upgrade from p.php"
echo "========================================================================="
echo "LTNMP is tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "========================================================================="
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="