#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包
## 组件安装脚本
## php C扩展/框架(Yaf,phalcon,swoole......)
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

. scripts/redis.sh
. scripts/phalcon.sh
. scripts/yaf.sh
. scripts/swoole.sh
. scripts/composer.sh
. scripts/zendloader.sh
. scripts/ionCube.sh

clear

echo "-------------------------------------------------------------------------"
echo ""
echo "     ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
echo ""
echo "     Automatic compilation(Tengine/nginx)+php+(Mariadb/Mysql)"
echo ""
echo "     Extend Module Install Panle"
echo ""
echo "     By:Andy http://www.moqifei.com"
echo ""
echo "-------------------------------------------------------------------------"
echo ""
echo ""
echo "1 : Install ${ltnmp_redis}"
echo "2 : Install ${ltnmp_phalcon}"
echo "3 : Install ${ltnmp_yaf}"
echo "4 : Install ${ltnmp_swoole}"
echo "5 : Install composer"
echo "6 : Install zend-loader"
echo "7 : Install ionCube"
echo ""

read -p "Enter your choice number (or exit): " action

case ${action} in
    1 )
        install_redis
    ;;
    2 )
        install_phalcon
    ;;
    3 )
        install_yaf
    ;;
    4 )
        install_swoole
    ;;
    5 )
        install_composer
    ;;
    6 )
        install_zend_loader
    ;;
    7 )
        install_ioncube
    ;;
    * )
        exit 1
    ;;
esac
