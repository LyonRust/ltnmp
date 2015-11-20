#!/bin/bash

# 系统编译组件检测、安装
check_system() {
    cat /etc/issue
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    echo -e "\n Memory is: ${MemTotal} MB "

    # 设置时区
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    yum install -y ntp
    ntpdate -u pool.ntp.org
    date

    rpm -qa|grep httpd
    rpm -e httpd
    rpm -qa|grep mysql
    rpm -e mysql
    rpm -qa|grep php
    rpm -e php

    yum -y remove httpd*
    yum -y remove php*
    yum -y remove mysql-server mysql
    yum -y remove php-mysql

    yum -y install yum-fastestmirror
    yum -y remove httpd
    yum -y update

    # 关闭Selinux
    if [ -s /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi

    cp /etc/yum.conf /etc/yum.conf.ltnmp
    sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

    #for packages in make cmake automake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel readline-devel re2c vim vim-minimal gettext gettext-devel gmp-devel pspell-devel libcap diffutils net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel tcl;
    #do yum -y install $packages; done
    yum -y install make cmake automake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel readline-devel re2c vim gettext gettext-devel gmp-devel pspell-devel libcap diffutils net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel tcl

    mv -f /etc/yum.conf.ltnmp /etc/yum.conf
}
