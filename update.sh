#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包
## 更新脚本
## by 技安(Andy) (http://www.moqifei.com)

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

# 当前路径
current_dir=$(pwd)

# 加载初始化脚本
. scripts/bootstrap.sh
. scripts/version.sh

## 检测系统参数
run

if [ "${DISTRO}" = "unknow" ]; then
    echo "Unable to get the release version of the operating system, or the system release version is not supported"
    exit 1
fi

## 加载各个发行版，数据库，PHP，web服务器等脚本
. scripts/${ANDY}.sh
. scripts/mariadb.sh
. scripts/mysql.sh
. scripts/tengine.sh
. scripts/nginx.sh
. scripts/php.sh
. scripts/phpmyadmin.sh
. scripts/end.sh

clear

echo "-------------------------------------------------------------------------"
echo ""
echo "     ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
echo ""
echo "     Automatic compilation(Tengine/nginx)+php+(Mariadb/Mysql)"
echo ""
echo "     By:Andy http://www.moqifei.com"
echo ""
echo "-------------------------------------------------------------------------"
echo ""
echo "1 : update ${ltnmp_php}"
echo "2 : update ${ltnmp_tengine}"
echo ""

read -p "Enter your choice number (or input exit): " action

case ${action} in
    1 )
        /root/ltnmp stop
        install_php
        /root/ltnmp start
    ;;
    2 )
        /root/ltnmp stop
        install_tengine
        /root/ltnmp start
    ;;
    * )
        exit 1
    ;;
esac
