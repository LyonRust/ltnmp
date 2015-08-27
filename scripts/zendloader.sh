#!/bin/bash

install_zend_loader() {
    echo "--------------------------------------------"
    echo ""
    echo "     Install zend-loader for php5.6"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    echo "Install ZendGuardLoader for PHP 5.6..."
    if [ "${is_64bit}" = "y" ] ; then
        tar -zxvf zend-loader-php5.6-linux-x86_64.tar.gz
        mv -f ./zend-loader-php5.6-linux-x86_64 /usr/local/zend
    else
        tar -zxvf zend-loader-php5.6-linux-i386.tar.gz
        mv -f ./zend-loader-php5.6-linux-i386 /usr/local/zend
    fi

    echo "Write ZendGuardLoader into php.ini..."
    cat >>/usr/local/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

[Zend ZendGuard Loader]
zend_extension=/usr/local/zend/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=

;opcache
;[Zend Opcache]
;zend_extension=/usr/local/zend/opcache.so
;opcache.memory_consumption=128
;opcache.interned_strings_buffer=8
;opcache.max_accelerated_files=4000
;opcache.revalidate_freq=60
;opcache.fast_shutdown=1
;opcache.enable_cli=1
;opcache end

;xcache
;xcache end
EOF

    /etc/init.d/php-fpm restart

}