#!/bin/bash

install_ioncube_php56()
{
    echo "--------------------------------------------"
    echo ""
    echo "     Install ionCube For PHP5.6"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    if [ "${is_64bit}" = "y" ] ; then
        tar -zxvf ioncube_loaders_lin_x86-64.tar.gz
        mv ./ioncube /usr/local/
    else
        tar -zxvf ioncube_loaders_lin_x86.tar.gz
        mv ./ioncube /usr/local/
    fi

    cat >/tmp/ionCube.ini<<EOF
[ionCube Loader]
zend_extension=/usr/local/ioncube/ioncube_loader_lin_5.6.so

EOF

    sed -i '/;ionCube/ {
r /tmp/ionCube.ini
}' /usr/local/php/etc/php.ini

    rm -f /tmp/ionCube.ini

    /etc/init.d/php-fpm restart

}