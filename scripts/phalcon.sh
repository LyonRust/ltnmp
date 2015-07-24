#!/bin/bash

install_phalcon() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall Phalcon-v2.0.6"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf cphalcon-phalcon-v2.0.6.tar.gz

    if [ "${is_64bit}" = "y" ] ; then
        cd cphalcon-phalcon-v2.0.6/build/64bits
    else
        cd cphalcon-phalcon-v2.0.6/build/32bits
    fi

    sed -i '/phalcon.so/d' /usr/local/php/etc/php.ini
    zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/"
    if [ -s "${zend_ext_dir}phalcon.so" ]; then
        rm -f "${zend_ext_dir}phalcon.so"
    fi

    /usr/local/php/bin/phpize
    ./configure --with-php-config=/usr/local/php/bin/php-config
    make && make install

    sed -i '/; Windows Extensions/i\extension=phalcon.so' /usr/local/php/etc/php.ini

    /etc/init.d/php-fpm restart

    echo "====== phalcon install completed ======"
    echo "phalcon installed successfully!"

}