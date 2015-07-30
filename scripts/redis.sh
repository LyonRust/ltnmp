#!/bin/bash

install_redis303() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall Redis-3.0.3"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf redis-3.0.3.tar.gz
    cd redis-3.0.3

    sed -i '/redis.so/d' /usr/local/php/etc/php.ini
    zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/"
    if [ -s "${zend_ext_dir}redis.so" ]; then
        rm -f "${zend_ext_dir}redis.so"
    fi

    if [ "${is_64bit}" = "y" ] ; then
        make PREFIX=/usr/local/redis install
    else
        make CFLAGS="-march=i686" PREFIX=/usr/local/redis install
    fi

    mkdir -p /usr/local/redis/etc/
    cp redis.conf  /usr/local/redis/etc/
    sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/etc/redis.conf
    sed -i 's/# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/etc/redis.conf

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp -s 127.0.0.1 --dport 6379 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp --dport 6379 -j DROP
        if [ "$ANDY" = "CentOS" ]; then
            service iptables save
        elif [ "$ANDY" = "Ubuntu" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi

    # 安装 php-redis扩展
    cd ${current_dir}/src
    tar -zxvf redis-2.2.7.tgz
    cd redis-2.2.7

    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    sed -i '/; Windows Extensions/i\extension=redis.so' /usr/local/php/etc/php.ini

    cp ${current_dir}/lib/init.d/redis /etc/init.d/redis
    chmod +x /etc/init.d/redis
    echo "Add to auto start..."

    /etc/init.d/php-fpm restart
    /etc/init.d/redis start

    chkconfig redis on

    echo "====== Redis install completed ======"
    echo "Redis installed successfully!"
}
