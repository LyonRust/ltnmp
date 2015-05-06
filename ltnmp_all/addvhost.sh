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
echo "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to add virtual host for ltanmp "
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="

if [ "$1" != "--help" ]; then

if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ] && [ -s /etc/init.d/php-fpm ]; then
	echo "PHP Default file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php52/sbin/php-fpm ] && [ -s /usr/local/php52/etc/php.ini ] && [ -s /usr/local/php52/bin/php ] && [ -s /etc/init.d/php-fpm52 ]; then
	echo "PHP52   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php53/sbin/php-fpm ] && [ -s /usr/local/php53/etc/php.ini ] && [ -s /usr/local/php53/bin/php ] && [ -s /etc/init.d/php-fpm53 ]; then
	echo "PHP53   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php54/sbin/php-fpm ] && [ -s /usr/local/php54/etc/php.ini ] && [ -s /usr/local/php54/bin/php ] && [ -s /etc/init.d/php-fpm54 ]; then
	echo "PHP54   ver file php-fpm [found] Install is OK  "
fi
if [ -s /usr/local/php55/sbin/php-fpm ] && [ -s /usr/local/php55/etc/php.ini ] && [ -s /usr/local/php55/bin/php ] && [ -s /etc/init.d/php-fpm55 ]; then
	echo "PHP55   ver file php-fpm [found] Install is OK  "
fi
	echo ""



	ver="1"
	ver0="Add Domain"

	echo "Add Domain or Del Domain you want:"
	echo "Add Domain	  please type: 1"
	echo "Del Domain	  please type: 0"
	echo ""
	read -p "Type 1 or 0 (Default: 1):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="1"
	fi

	if [ "$ver" != 1 ] && [ "$ver" != 0 ]; then
	echo "Error: You must input  1 or 0!!"
	exit 1
	fi

	if [ "$ver" = "0" ]; then

		echo "You will Del Domain !!"
		ver0="Del Domain"
	fi





#-----------Delete  $domain.conf

if [ "$ver" = 0 ] ; then
	echo ""
	read -p "Please input domain:" domain
	if [ "$domain" = "" ]; then
		echo "You must  input Domain !"
		exit 1
	fi

	if [ ! -f "/usr/local/nginx/conf/vhost/$domain.conf" ]; then
	echo "==========================="
	echo "/usr/local/nginx/conf/vhost/$domain.conf  not found !! EXIT !"
	echo ""
        exit 1

	else
	echo "==========================="
	echo "/usr/local/nginx/conf/vhost/$domain.conf  [found] !!  Delete it !"
	echo ""
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
	echo "Press any key to Delete $domain...or Press Ctrl+c to cancel"
	char=`get_char`




rm /usr/local/nginx/conf/vhost/$domain.conf

echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo ""
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload

	echo ""
	echo "Del $domain OK"
	echo ""
       exit 1

fi






#-----------Add  $domain.conf

	ver1a="0"
	echo "input Add Domain VER you want:"
	echo "Add Domain to php5.5.*     please type: 55"
	echo "Add Domain to php5.4.*     please type: 54"
	echo "Add Domain to php5.3.*     please type: 53"
	echo "Add Domain to php5.2.*     please type: 52"
	echo "Add Domain to Default php  please type: 0"
	echo ""
	read -p "Type 55 or 54 or 53 or 52 or 0 (Default:$ver1a ):" ver1
	echo ""
	if [ "$ver1" = "" ]; then
		ver1="$ver1a"
	fi

	if [ "$ver1" != 55 ] && [ "$ver1" != 54 ] && [ "$ver1" != 53 ] && [ "$ver1" != 52 ] && [ "$ver1" != 0 ]; then
	echo "Error: You must input  55 or 54 or 53 or 52 or 0 !!"
	exit 1
	fi

	if [ "$ver1" = "0" ]; then
		ver1=""
	fi


if [ -s /usr/local/php$ver1/sbin/php-fpm ] && [ -s /usr/local/php$ver1/etc/php.ini ] && [ -s /usr/local/php$ver1/bin/php ]; then
	echo "PHP$ver1 php-fpm ver file [found] "
	echo ""

	else
	echo "PHP$ver1 php-fpm ver file not found  EXIT ! "
	echo ""
	exit 1
fi


	read -p "Please input domain:" domain
	if [ "$domain" = "" ]; then
		echo "You must  input Domain !"
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

	if [ "$add_more_domainame" = 'y' ]; then

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

	echo "==========================="
	echo "Allow Rewrite rule? (y/n)"
	echo "==========================="
	read allow_rewrite

	if [ "$allow_rewrite" = 'n' ]; then
		rewrite="none"
	else
		rewrite="other"
		echo "Please input the rewrite of programme :"
		echo "pathinfo,wordpress,discuz,typecho,sablog,dabr rewrite was exist."
		read -p "(Default rewrite: other):" rewrite
		if [ "$rewrite" = "" ]; then
			rewrite="other"
		fi
	fi
	echo "==========================="
	echo You choose rewrite="$rewrite"
	echo "==========================="

	echo "==========================="
	echo "Allow access_log? (y/n)"
	echo "==========================="
	read access_log

	if [ "$access_log" = 'n' ]; then
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

if [ ! -f /usr/local/nginx/conf/$rewrite.conf ]; then
  echo "Create Virtul Host ReWrite file......"
	touch /usr/local/nginx/conf/$rewrite.conf
	echo "Create rewirte file successful,now you can add rewrite rule into /usr/local/nginx/conf/$rewrite.conf."
else
	echo "You select the exist rewrite rule:/usr/local/nginx/conf/$rewrite.conf"
fi

cat >/usr/local/nginx/conf/vhost/$domain.conf<<eof
$alf
server
	{
		listen       80;
		server_name $domain$moredomainame;
		index index.html index.htm index.php default.html default.htm default.php;
		root  $vhostdir;

		include $rewrite.conf;
		location ~ .*\.(php|php5)?$
			{
				try_files \$uri =404;
				fastcgi_pass  unix:/tmp/php-cgi$ver1.sock;
				fastcgi_index index.php;
				include fcgi.conf;
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

cur_php_version=`/usr/local/php/bin/php -r 'echo PHP_VERSION;'`

if echo "$cur_php_version" | grep -q "5.3." ||  echo "$cur_php_version" | grep -q "5.4." || echo "$cur_php_version" | grep -q "5.5."
then
cat >>/usr/local/php/etc/php.ini<<eof
[HOST=$domain]
open_basedir=$vhostdir/:/tmp/
[PATH=$vhostdir]
open_basedir=$vhostdir/:/tmp/
eof
/etc/init.d/php-fpm restart
fi

echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload
echo "Anti-Cross Site settings......"
chmod -R 751  /usr/local/nginx/conf/vhost
chmod 0751 /home/www
chmod 0751 /home
/etc/init.d/nginx restart
/etc/init.d/php-fpm restart

echo "========================================================================="
echo "Add Virtual Host for LTNMP  ,  Written by php360 "
echo "========================================================================="
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "Your domain:$domain"
echo "Directory of $domain:$vhostdir"
echo ""
echo "========================================================================="
fi