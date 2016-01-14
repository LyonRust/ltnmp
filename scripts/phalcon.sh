#!/bin/bash

install_phalcon() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall ${ltnmp_phalcon}"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf ${ltnmp_phalcon}.tar.gz

    if [ "${is_64bit}" = "y" ] ; then
        cd ${ltnmp_phalcon}/build/64bits
    else
        cd ${ltnmp_phalcon}/build/32bits
    fi

    sed -i '/phalcon.so/d' /usr/local/php/etc/php.ini
    zend_ext_dir=${ltnmp_php_extension}
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