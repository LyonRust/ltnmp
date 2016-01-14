#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包(卸载程序)
## by 技安(Andy) (http://www.moqifei.com)

## 检测是否是root账户权限
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

## 当前路径
current_dir=$(pwd)

## 加载初始化脚本
. scripts/bootstrap.sh
. scripts/version.sh

## 检测系统参数
run

if [ "${DISTRO}" = "unknow" ]; then
    echo "Unable to get the release version of the operating system, or the system release version is not supported"
    exit 1
fi

clear

echo "-------------------------------------------------------------------------"
echo ""
echo "  ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
echo "  Automatic compilation(Tengine/nginx)+php+(Mariadb/Mysql)"
echo "  By:Andy http://www.moqifei.com"
echo ""
echo "-------------------------------------------------------------------------"
echo ""
echo "  1 : Remove ltnmp v${ltnmp_version}"
echo "          (include Phalcon,Yaf,Swoole,if installed)"
echo "  2 : Remove ${ltnmp_redis}"
echo ""


remove_ltnmp() {
    echo -e "\n=====Remove ltnmp=====\n"
    /root/ltnmp stop

    ## 删除启动项
    # 删除Tengine/nginx
    remove_startup nginx
    # 删除Mariadb/Mysql数据库
    remove_startup mysql
    # 删除php
    remove_startup php-fpm

    ## 删除文件
    echo "Remove ltnmp directory and files"
    rm -rf /usr/local/nginx
    time=$(date +%Y%m%d%H%M%S)
    mkdir -p /home/backup/db/${time}
    if [ -d "/usr/local/mysql/data" ] ; then
        mv /usr/local/mysql/data /home/backup/db/${time}/
        echo "mysql data is copy into /home/backup/db/${time}/"
    fi
    rm -rf /usr/local/mysql
    rm -rf /usr/local/php
    rm -rf /usr/local/zend
    rm -rf /usr/local/ioncube
    rm -f /etc/my.cnf
    rm -f /etc/init.d/nginx
    rm -f /etc/init.d/mysql
    rm -f /etc/init.d/php-fpm
    rm -f /boot/ltnmp
    rm -f /bin/ltnmp
    rm -rf /boot/ltnmp-install.log*
    rm -rf /usr/lib/mysql
    rm -rf /usr/include/mysql
    rm -rf /usr/bin/mysql
    rm -rf /usr/bin/mysqldump
    rm -rf /usr/bin/myisamchk
    rm -rf /usr/bin/mysqld_safe
    echo "ltnmp is removed..."
}

remove_redis() {
    echo -e "\n=====Remove redis=====\n"
    /root/ltnmp stop
    /etc/init.d/redis stop

    remove_startup redis

    ## 删除文件
    echo "Remove redis directory and files"
    rm -rf /usr/local/redis

    ## 关闭php的redis扩展
    sed -i '/extension=redis.so/d' /usr/local/php/etc/php.ini

    /root/ltnmp start

    echo ""
    echo "redis is removed..."
}

action="exit"
read -p "Enter your choice (1, 2 or exit): " action

case ${action} in
    1 )
        echo "You will remove ltnmp"
        echo "Please backup your configure files and mariadb/mysql data!!!"
        echo ""
        echo "The following directory or files will be remove!"
        cat << EOF
/usr/local/nginx
/usr/local/mysql
/usr/local/php
/etc/init.d/nginx
/etc/init.d/mysql
/etc/init.d/php-fpm
/usr/local/zend
/usr/local/ioncube
/etc/my.cnf
/root/ltnmp
/bin/ltnmp
/boot/ltnmp-install.log
/usr/lib/mysql
/usr/include/mysql
/usr/bin/mysql
/usr/bin/mysqldump
/usr/bin/myisamchk
/usr/bin/mysqld_safe
EOF
        start=""
        read -p "Please enter 'ltnmp' to start: " start
        if [ "${start}" = "ltnmp" ]; then
            remove_ltnmp
        else
            exit 1
        fi
    ;;
    2 )
        start=""
        read -p "Please enter 'redis' to start: " start
        if [ "${start}" = "redis" ]; then
            remove_redis
        else
            exit 1
        fi
    ;;
    * )
        exit 1
    ;;
esac
