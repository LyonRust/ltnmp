#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

clear
printf "=======================================================================\n"
printf "Install Apache for LTNMP  ,  Written by php360 \n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to install Apache for ltnmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"
cur_dir=$(pwd)
ipv4=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`

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
	echo "Press any key to start install Apache for LNMP or Press Ctrl+C to cancel..."
	char=`get_char`

printf "===================== Check And Download Files =================\n"

if [ -s httpd-2.4.6.tar.gz ]; then
  echo "httpd-2.4.6.tar.gz [found]"
  else
  echo "Error: httpd-2.4.6.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/httpd-2.4.6.tar.gz
  #wget -c http://ltanmp.googlecode.com/files/httpd-2.4.6.tar.gz
fi

if [ -s mod_rpaf-0.6.tar.gz ]; then
  echo "mod_rpaf-0.6.tar.gz [found]"
  else
  echo "Error: mod_rpaf-0.6.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/mod_rpaf-0.6.tar.gz
  #wget -c http://ltanmp.googlecode.com/files/mod_rpaf-0.6.tar.gz
fi

if [ -s php-5.2.17.tar.gz ]; then
  echo "php-5.2.17.tar.gz [found]"
  else
  echo "Error: php-5.2.17.tar.gz not found!!!download now......"
  wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/php-5.2.17.tar.gz
  #wget -c http://ltanmp.googlecode.com/files/php-5.2.17.tar.gz
fi
printf "=========================== install Apache ======================\n"

echo "Stoping Nginx..."
/etc/init.d/nginx stop
echo "Stoping MySQL..."
/etc/init.d/mysql stop
echo "Stoping PHP-FPM..."
/etc/init.d/php-fpm stop
if [ -s /etc/init.d/memceached ]; then
  echo "Stoping Memcached..."
  /etc/init.d/memcacehd stop
fi

echo "Backup old php configure files....."
mkdir /root/ltnmpbackup/
cp /root/ltnmp /root/ltnmpbackup/
cp /usr/local/php/etc/php.ini /root/ltnmpbackup/
cp /usr/local/php/etc/php-fpm.conf /root/ltnmpbackup/

cd $cur_dir
rm -rf httpd-2.4.6/
tar zxvf httpd-2.4.6.tar.gz
cd httpd-2.4.6/
./configure --prefix=/usr/local/apache --enable-headers --enable-mime-magic --enable-proxy --enable-so --enable-rewrite --enable-ssl --enable-deflate --enable-suexec --disable-userdir --with-included-apr --with-mpm=prefork --with-ssl=/usr --disable-userdir --disable-cgid --disable-cgi --with-expat=builtin
make && make install
cd ..

mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
\cp $cur_dir/conf/httpd.conf /usr/local/apache/conf/httpd.conf
\cp $cur_dir/conf/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf
\cp $cur_dir/conf/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
\cp $cur_dir/conf/httpd-mpm.conf /usr/local/apache/conf/extra/httpd-mpm.conf
\cp $cur_dir/conf/rpaf.conf /usr/local/apache/conf/extra/rpaf.conf

sed -i 's/#ServerName www.example.com:80/ServerName www.05gzs.com:88/g' /usr/local/apache/conf/httpd.conf
sed -i 's/ServerAdmin you@example.com/ServerAdmin '$ServerAdmin'/g' /usr/local/apache/conf/httpd.conf
sed -i 's/webmaster@example.com/'$ServerAdmin'/g' /usr/local/apache/conf/extra/httpd-vhosts.conf
mkdir -p /usr/local/apache/conf/vhost
cat >>/usr/local/apache/conf/httpd.conf<<EOF
Include conf/vhost/*.conf
EOF

tar -zxvf mod_rpaf-0.6.tar.gz
cd mod_rpaf-0.6/
/usr/local/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
cd ..

ln -s /usr/local/lib/libltdl.so.3 /usr/lib/libltdl.so.3

#sed -i 's#your_ips#'$ipv4'#g' /usr/local/apache/conf/extra/rpaf.conf
echo "Stop php-fpm....."

rm -rf /usr/local/php/
cd $cur_dir
if [ -s php-5.2.17 ]; then
rm -rf php-5.2.17
fi
tar zxvf php-5.2.17.tar.gz
cd php-5.2.17/
wget -c http://www.05gzs.com/ltnmp/php-5.2.17-max-input-vars.patch
patch -p1 < php-5.2.17-max-input-vars.patch
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --with-mime-magic

if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    cd ext/openssl/
wget -c http://www.05gzs.com/ltnmp/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    patch -p3 <debian_patches_disable_SSLv2_for_openssl_1_0_0.patch
    cd ../../
fi

rm -rf libtool
cp /usr/local/apache/build/libtool .

make ZEND_EXTRA_LIBS='-liconv'
make install

mkdir -p /usr/local/php/etc
cp php.ini-dist /usr/local/php/etc/php.ini
cd ../

cd $cur_dir/php-5.2.17/ext/pdo_mysql/
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install

cd $cur_dir/
# php extensions
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "memcache.so"\nextension = "pdo_mysql.so"\n#' /usr/local/php/etc/php.ini
sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = phpinfo,passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,popen,pclose,proc_open,proc_close,proc_nice,proc_terminate,leak,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,pcntl_exec,popepassthru,stream_socket_server,putenv,posix_getpwuid,pfsockopen,psockopen,php_u,crack_closedictescap,crack_getlastmessage,fsocket,crack_opendict,eshellcmd/g' /usr/local/php/etc/php.ini

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
        tar zxvf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
else
        wget -c http://git.oschina.net/php360/ltnmp/raw/master/ltnmp_all/ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	tar zxvf ZendOptimizer-3.3.9-linux-glibc23-i386.tar.gz
	mkdir -p /usr/local/zend/
	cp ZendOptimizer-3.3.9-linux-glibc23-i386/data/5_2_x_comp/ZendOptimizer.so /usr/local/zend/
fi

cat >>/usr/local/php/etc/php.ini<<EOF
;eaccelerator

;ionCube

[Zend Optimizer]
zend_optimizer.optimization_level=1
zend_extension="/usr/local/zend/ZendOptimizer.so"
EOF

cd $cur_dir
cp conf/proxy.conf /usr/local/nginx/conf/proxy.conf
mv /usr/local/nginx/conf/nginx.conf /root/ltnmpbackup/
cp conf/nginx_a.conf /usr/local/nginx/conf/nginx.conf

echo "Download new Apache init.d file......"
wget -c http://www.05gzs.com/ltnmp/init.d.httpd
cp init.d.httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd

echo "Test Nginx configure files..."
/usr/local/nginx/bin/nginx -t
echo "ReStarting Nginx......"
/etc/init.d/nginx restart
echo "Starting Apache....."
/etc/init.d/httpd restart

echo "Remove old startup files and Add new startup file....."
if cat /etc/issue | grep -Eqi '(Debian|Ubuntu)';then
    update-rc.d -f httpd defaults
    update-rc.d -f php-fpm remove
else
	sed -i '/php-fpm/'d /etc/rc.local
	chkconfig --level 345 php-fpm off
	chkconfig --level 345 httpd on
fi

cd $cur_dir
rm -f /etc/init.d/php-fpm
mv /root/vhost.sh /root/ltnmp.vhost.sh
cp vhost_ltanmp.sh /root/vhost.sh
chmod +x /root/vhost.sh
cp ltanmp /root/
chmod +x /root/ltanmp

printf "====================== Upgrade to LTNMP completed =====================\n"
printf "You have successfully upgrade from ltnmp ,enjoy it!\n"
printf "=======================================================================\n"
printf "LTNMP is a tool to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux \n"
printf "This script is a tool to upgrade from ltnmp to ltanmp \n"
printf "\n"
printf "For more information please visit http://www.05gzs.com \n"
printf "=======================================================================\n"