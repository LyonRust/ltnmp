#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Vsftpd for LTNMP  ,  Written by php360 "
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install VSftp for LTNMP "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo "========================================================================="
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
	echo "Press any key to start install VSftpd..."
	char=`get_char`
if [ -s vsftpd-3.0.2.tar.gz ]; then
	echo "vsftpd-3.0.2.tar.gz [found]"
else
	echo "Error: vsftpd-3.0.2.tar.gz not found,download it......"
	wget -c http://www.05gzs.com/ltnmp/vsftpd-3.0.2.tar.gz
fi
#wget -c http://ltanmp.googlecode.com/files/vsftpd-3.0.2.tar.gz
echo "download vsftpd package completed!"
echo "installing vsftpd 3.0.2......."

useradd nobody

tar zxf vsftpd-3.0.2.tar.gz
cd vsftpd-3.0.2/
mkdir /usr/local/man/man8
mkdir /usr/local/man/man5
make && make install
cd ../

cp conf/vsftpd.conf /etc/
mkdir /etc/vsftpd
touch /etc/vsftpd/chroot_list
echo "/usr/local/sbin/vsftpd &" >> /etc/rc.local
mkdir /var/ftp
touch /etc/vsftpd/userlist.chroot
touch /etc/vsftpd/userlist_deny.chroot
touch /var/log/vsftpd.log
mkdir -p /usr/share/empty

/usr/local/sbin/vsftpd &
setsebool -P ftpd_disable_trans on
/sbin/iptables -I INPUT -p tcp --dport 21 -j ACCEPT
/etc/rc.d/init.d/iptables save
/etc/init.d/iptables restart
useradd -d /home/www/default -s /sbin/nologin adminftp
pkill vsftpd
/usr/local/sbin/vsftpd &

clear
echo "========================================================================="
echo "Vsftpd for LTNMP  ,  Written by php360 "
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to install VSftp for LTNMP "
echo ""
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "The path of some dirs:"
echo "run vsftpd:   /usr/local/sbin/vsftpd & "
echo "kill vsftpd process:     pkill vsftpd "
echo "test ftp user: "adminftp", you need run "passwd adminftp" to modify password!!! or delete the user!"
echo "web dir      home/www/default"
echo ""
echo "========================================================================="