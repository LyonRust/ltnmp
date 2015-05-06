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
echo "Upgrade php-fpm files,  Written by www.05gzs.com"
echo "========================================================================="

cur_dir=$(pwd)



if [ -s /etc/init.d/httpd ] && [ -s /usr/local/apache ]; then
echo "LNMPA Can't Upgrade php-fpm file..... Need LNMP....."
exit 1
fi


now_php_version=`php -r 'echo PHP_VERSION;'`
echo $now_php_version | grep '5.2.*'
if [ $? -eq 0 ]; then
echo "PHP 5.2.* Can't Upgrade php-fpm file...... "
exit 1
fi



	ver="256"
	echo "Which version do you want to install:"
	echo "Install in  VPS <=  RAM256 M      please type: 256"
	echo "Install in  VPS <>  RAM512 M      please type: 512"
	echo "Install in  VPS =>  RAM1000M      please type: 1000"
	read -p "Type 256 or 512 or  1000 (Default version 256):" ver

	if [ "$ver" = "" ]; then
		ver="256"
	fi


	if [ "$ver" != 256 ] && [ "$ver" != 512 ] && [ "$ver" != 1000 ]; then
        echo ""
	echo "Error: You must input  256 or 512 or  1000 !!"
	exit 1
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
       echo "You will install "$ver"M VPS php-fpm files"
	echo "Press any key to start install "$ver"M VPS ...or Press Ctrl+c to cancel"

char=`get_char`


#Backup old php-fpm files
echo ""
echo "Backup old php-fpm files to /root ......"
echo ""
cp /usr/local/php/etc/php-fpm.conf /root/php-fpm.conf.old.bak



if [ "$ver" = "256" ]; then
echo "Creating new "$ver"M VPS  php-fpm  file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 40
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

fi


if [ "$ver" = "512" ]; then

echo "Creating new "$ver"M VPS php-fpm  file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 60
pm.start_servers = 6
pm.min_spare_servers = 3
pm.max_spare_servers = 9
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

fi


if [ "$ver" = "1000" ]; then

echo "Creating new "$ver"M VPS php-fpm  file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
user = www
group = www
pm = dynamic
pm.max_children = 80
pm.start_servers = 8
pm.min_spare_servers = 4
pm.max_spare_servers = 12
pm.max_requests = 2048
request_terminate_timeout = 180
pm.process_idle_timeout = 10
EOF

fi

/etc/init.d/php-fpm restart

echo ""
printf "============== Upgrade "$ver"M VPS php-fpm files  completed ===============\n"
echo ""
echo "please feedback from Forum : http://www.05gzs.com"
echo ""
echo "========================================================================="