#!/bin/bash

install_yaf() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall Yaf-2.3.3"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf yaf-2.3.3.tgz
    cd yaf-2.3.3

    sed -i '/yaf.so/d' /usr/local/php/etc/php.ini
    zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/"
    if [ -s "${zend_ext_dir}yaf.so" ]; then
        rm -f "${zend_ext_dir}yaf.so"
    fi

    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    sed -i '/; Windows Extensions/i\extension=yaf.so' /usr/local/php/etc/php.ini

    /etc/init.d/php-fpm restart

    echo "====== yaf install completed ======"
    echo "yaf installed successfully!"

}