#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Add Virtual Host for LTNMP  ,  Written by php360 "
echo "========================================================================="
echo "LTNMP is a tool to auto-compile & install Tengine+MySQL+PHP+Apache on Linux "
echo "This script is a tool to add virtual host for ltnmp "
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="

if [ "$1" != "--help" ]; then

	domain="www.05gzs.com"
	read -p "Please input domain:" domain
	if [ "$domain" = "" ]; then
		echo "Error: Domain Name Can't be empty!!"
		exit 1
	fi
	if [ ! -f "/usr/local/nginx/conf/vhost/$domain.conf" ]; then
	echo "==========================="
	echo "domain=$domain"
	echo "==========================="
	else
	echo "==========================="
	echo "$domain is exist!"
	echo "==========================="
	fi

	echo "Do you want to add more domain name? (y/n)"
	read add_more_domainame

	if [ "$add_more_domainame" == 'y' ]; then

	  echo "Type domainname,example(my.05gzs.com blog.05gzs.com):"
	  read moredomain
          echo "==========================="
          echo domain list="$moredomain"
          echo "==========================="
	  moredomainame=" $moredomain"
	fi

	vhostdir="/home/www/$domain"
	echo "Please input the directory for the domain:$domain :"
	read -p "(Default directory: /home/www/$domain):" vhostdir
	if [ "$vhostdir" = "" ]; then
		vhostdir="/home/www/$domain"
	fi
	echo "==========================="
	echo Virtual Host Directory="$vhostdir"
	echo "==========================="

#set Server Administrator Email Address

	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

	echo "==========================="
	echo "Allow access_log? (y/n)"
	echo "==========================="
	read access_log

	if [ "$access_log" == 'n' ]; then
	  al="access_log off;"
	else
	  echo "Type access_log name(Default access log file:$domain.log):"
	  read al_name
	  if [ "$al_name" = "" ]; then
		al_name="$domain"
	  fi
	  alf="log_format  $al_name  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
             '\$status \$body_bytes_sent \"\$http_referer\" '
             '\"\$http_user_agent\" \$http_x_forwarded_for';"
	  al="access_log  /home/wwwlogs/$al_name.log  $al_name;"
	echo "==========================="
	echo You access log file="$al_name.log"
	echo "==========================="
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
	echo "Press any key to start create virtul host..."
	char=`get_char`


if [ ! -d /usr/local/nginx/conf/vhost ]; then
	mkdir /usr/local/nginx/conf/vhost
fi

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
touch /home/wwwlogs/$al_name.log
echo "set permissions of Virtual Host directory......"
chmod -R 755 $vhostdir
chown -R www:www $vhostdir

cat >/usr/local/nginx/conf/vhost/$domain.conf<<eof
$alf
server
	{
		listen       80;
		server_name $domain$moredomainame;
		index index.html index.htm index.php default.html default.htm default.php;
		root  $vhostdir;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:88;
			include proxy.conf;
			}

		location ~ .*\.(php|php5)?$
			{
				proxy_pass http://127.0.0.1:88;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
eof

cat >/usr/local/apache/conf/vhost/$domain.conf<<eof
<VirtualHost *:88>
ServerAdmin webmaster@example.com
php_admin_value open_basedir "$vhostdir:/tmp/:/var/tmp/:/proc/"
DocumentRoot "$vhostdir"
ServerName $domain
ErrorLog "logs/$al_name-error_log"
CustomLog "logs/$al_name-access_log" common
</VirtualHost>
eof

if [ "$access_log" == 'n' ]; then
sed -i 's/ErrorLog/#ErrorLog/g' /usr/local/apache/conf/vhost/$domain.conf
sed -i 's/CustomLog/#CustomLog/g' /usr/local/apache/conf/vhost/$domain.conf
fi

if [ "$add_more_domainame" == 'y' ]; then
sed -i "/ServerName/a\
ServerAlias $moredomainame" /usr/local/apache/conf/vhost/$domain.conf
fi

echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload
echo "Restart Apache......"
/etc/init.d/httpd restart
echo "Anti-Cross Site settings......"
chmod 0751 /home/www
chmod 0751 /home
#/etc/init.d/nginx restart
/etc/init.d/php-fpm restart

echo "========================================================================="
echo "Add Virtual Host for LTNMP  ,  Written by php360 "
echo "========================================================================="
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "Your domain:$domain $moredomainame"
echo "Directory of $domain:$vhostdir"
echo ""
echo "========================================================================="
fi
