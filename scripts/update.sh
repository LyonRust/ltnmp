#!/bin/bash

update() {
    clear
    echo "---------------------------------------------------------------------"
    echo ""
    echo "     ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
    echo ""
    echo "     Automatic compilation(Tengine/nginx)+php+(Mariadb/Mysql)"
    echo ""
    echo "     Extend Module Install Panle"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "---------------------------------------------------------------------"
    echo ""
    echo "1 : update php-5.6.12"
    echo ""

    action='exit'
    read -p "Enter your choice (1 or exit): " action

    case ${action} in
        1 )
            /root/ltnmp stop
            install_php
            /root/ltnmp start
        ;;
        * )
            exit 1
        ;;
    esac
}
