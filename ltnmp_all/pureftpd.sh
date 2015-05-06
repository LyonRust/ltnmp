#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi
clear
printf "=========================================================================\n"
printf "Pureftpd for LTNMP  ,  Written by php360 \n"
printf "=========================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install pureftpd for ltanmp \n"
printf "\n"
printf "For more information please visit http://www.05gzd.com \n"
printf "\n"
printf "Usage: ./pureftpd.sh \n"
printf "=========================================================================\n"
cur_dir=$(pwd)


	ver="1"
	echo "Which version do you want to install:"
	echo "Install    Pureftpd      	please type: 1"
	echo "Uninstall  Pureftpd      	please type: 0"
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


echo "Are you sure uninstall Pureftpd? (y/n)"
read -p "(Default: n):" UNINSTALL
if [ -z $UNINSTALL ]; then
	UNINSTALL="n"
fi
if [ "$UNINSTALL" != "y" ]; then
	clear
	echo "==========================="
	echo "You canceled the uninstall!"
	echo "==========================="
	exit
else
	echo "---------------------------"
	echo "Yes, I decided to uninstall!"
	echo "---------------------------"
	echo ""
fi

echo ""
read -p "Please enter the root password of MySQL:" MYSQL_ROOT_PWD
if [ -z $MYSQL_ROOT_PWD ]; then
	MYSQL_ROOT_PWD=""
fi
echo "---------------------------"
echo "MySQL root password = $MYSQL_ROOT_PWD"
echo "---------------------------"
echo ""

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
echo "Press any key to start uninstall Pure-FTPd...Or Ctrl+C cancel and exit ?"
echo ""
char=`get_char`

if [ "$UNINSTALL" = 'y' ]; then

	echo "---------- Pureftpd ----------"

	if cat /proc/version | grep -Eqi '(redhat|centos)';then
		chkconfig pureftpd off
	elif cat /proc/version | grep -Eqi '(debian|ubuntu)';then
		update-rc.d -f pureftpd remove
	fi

	rm -rf /usr/local/pureftpd
	rm -rf /home/www/default/ftp
	rm -rf /etc/init.d/pureftpd
	rm -rf /root/pureftpd

	echo "---------- MySQL ----------"

	mysql -uroot -p$MYSQL_ROOT_PWD -e"drop database pureftpd;Drop USER pureftpd@localhost;"

	clear
	echo "==========================="
	echo "Uninstall completed!"
	echo "For more information please visit http://www.05gzd.com"
	echo "==========================="
fi


  else
echo "Please enter the IP address of ftp server:"
TEMP_IP=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`
read -p "(e.g: $TEMP_IP):" IP_ADDRESS
if [ -z $IP_ADDRESS ]; then
	IP_ADDRESS="$TEMP_IP"
fi
echo "---------------------------"
echo "IP address = $IP_ADDRESS"
echo "---------------------------"
echo ""

#set mysql root password
echo ""
read -p "Please enter the root password of MySQL:" MYSQL_ROOT_PWD
if [ -z $MYSQL_ROOT_PWD ]; then
	MYSQL_ROOT_PWD=""
fi
echo "---------------------------"
echo "MySQL root password = $MYSQL_ROOT_PWD"
echo "---------------------------"
echo ""

#set password of mysql ftp user
echo "Please enter the ftpuser password of MySQL:"
read -p "(Default password: 123456):" FTP_USER_PWD
if [ -z "$FTP_USER_PWD" ]; then
	FTP_USER_PWD="123456"
fi
echo "---------------------------"
echo "FTP_USER_PWD = $FTP_USER_PWD"
echo "---------------------------"
echo ""

#set password of User manager
echo "Please enter the admin password of PureFTPD:"
read -p "(Default password: 123456):" FTP_ADMIN_PWD
if [ -z "$FTP_ADMIN_PWD" ]; then
	FTP_ADMIN_PWD="123456"
fi
echo "---------------------------"
echo "FTP_ADMIN_PWD = $FTP_ADMIN_PWD"
echo "---------------------------"
echo ""

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
echo "Press any key to start install Pure-FTPd...Or Ctrl+C cancel and exit ?"
echo ""
char=`get_char`

echo "================Pureftpd Install==============="

echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf
ldconfig

if [ ! -s pure-ftpd-*.tar.gz ]; then
wget -c http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
fi
tar -zxf pure-ftpd-*.tar.gz
cd pure-ftpd-*/

./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 \
--with-mysql=/usr/local/mysql \
--with-altlog \
--with-cookie \
--with-diraliases \
--with-ftpwho \
--with-language=simplified-chinese \
--with-paranoidmsg \
--with-peruserlimits \
--with-quotas \
--with-ratios \
--with-virtualroot \
--with-uploadscript \
--with-shadow \
--with-sysquotas \
--with-throttling \
--with-virtualchroot \
--with-virtualhosts \
--with-welcomemsg
make && make install

cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/pure-config.pl
chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
mkdir /usr/local/pureftpd/etc/
cp $cur_dir/conf/pureftpd.conf /usr/local/pureftpd/etc/pureftpd.conf
cp $cur_dir/conf/pureftpd-mysql.conf /usr/local/pureftpd/etc/pureftpd-mysql.conf
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' /usr/local/pureftpd/etc/pureftpd-mysql.conf

cp $cur_dir/conf/pureftpd.mysql /tmp/pureftpd.mysql
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' /tmp/pureftpd.mysql
sed -i 's/FTP_ADMIN_PWD/'$FTP_ADMIN_PWD'/g' /tmp/pureftpd.mysql
/usr/local/mysql/bin/mysql -u root -p$MYSQL_ROOT_PWD < /tmp/pureftpd.mysql
rm -f /tmp/pureftpd.mysql
echo "================User manager for PureFTPd==============="

cd $cur_dir

if [ ! -s ftp_*.tar.gz ]; then
wget -c http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz
fi

tar -zxf ftp_*.tar.gz
mv $cur_dir/ftp /home/www/default/
chown www -R /home/www/default/ftp/
cp $cur_dir/conf/config.php /home/www/default/ftp/config.php
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' /home/www/default/ftp/config.php
sed -i 's/IP_ADDRESS/'$IP_ADDRESS'/g' /home/www/default/ftp/config.php

UNUM=`awk -F: '$1=="www"{print $3}' /etc/passwd`
GNUM=`awk -F: '$1=="www"{print $4}' /etc/passwd`
sed -i 's/65534/'$UNUM'/' /home/www/default/ftp/config.php
sed -i 's/31/'$GNUM'/' /home/www/default/ftp/config.php
mv /home/www/default/ftp/install.php /home/www/default/ftp/install.php.bak

cd $cur_dir
cp pureftpd /root/pureftpd
chmod +x /root/pureftpd

if [ -s init.d.pureftpd ]; then
	echo "init.d.pureftpd [found]"
else
	echo "init.d.pureftpd not found, download it......"
	wget -c http://www.05gzs.com/ltnmp/init.d.pureftpd
fi
#wget -c http://ltanmp.googlecode.com/files/init.d.pureftpd
cp init.d.pureftpd /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
chkconfig pureftpd on

if [ -s /etc/debian_version ]; then
update-rc.d pureftpd defaults
elif [ -s /etc/redhat-release ]; then
chkconfig --level 345 pureftpd on
fi

if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
/sbin/iptables -I INPUT -p tcp --dport 20 -j ACCEPT
/sbin/iptables-save
fi
chown -R $UNUM:$GNUM /home/www/*
/etc/init.d/pureftpd start
clear
printf "=======================================================================\n"
printf "Install Pure-FTPd completed,enjoy it!\n"
printf "Now you enter http://youdomain.com/ftp/ in you Web Browser to manager FTP users\n"
printf "Your password of mysql ftp user was:$FTP_USER_PWD\n"
printf "Your password of User manager was:$FTP_ADMIN_PWD\n"
printf "=======================================================================\n"
printf "Install Pure-FTPd for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install Pure-FTPd for ltanmp \n"
printf "Usage: /root/pureftpd {start|stop|restart|status} \n"
printf "For more information please visit http://www.05gzd.com \n"
printf "=======================================================================\n"
fi