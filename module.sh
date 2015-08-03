#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包
## 组件安装脚本(redis,memcached,hhvm,eaccelerator,xcache,imageMagick)
## php C扩展/框架(Yaf,phalcon,swoole)
## by 安迪(Andy) (http://www.moqifei.com)

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

. scripts/redis.sh
. scripts/phalcon.sh
. scripts/yaf.sh
. scripts/swoole.sh
. scripts/composer.sh

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
echo "     1 : Install Redis-3.0.3"
echo "     2 : Install Phalcon-v2.0.6"
echo "     3 : Install Yaf-2.3.3"
echo "     4 : Install Swoole-1.7.17"
echo "     5 : Install composer-1.0-dev"

action='exit'
read -p "Enter your choice (1,2,3,4,5 or exit): " action

case ${action} in
    1 )
        install_redis303
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
    * )
        exit 1
    ;;
esac







