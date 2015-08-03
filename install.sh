#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包
## 安装Tengine/Nginx,PHP,Maraidb/Mysql.
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


## 加载各个发行版，数据库，PHP，web服务器等脚本
. scripts/${ANDY}.sh
. scripts/mariadb.sh
. scripts/tengine.sh
. scripts/nginx.sh
. scripts/php.sh
. scripts/ionCube.sh
. scripts/phpmyadmin.sh
. scripts/end.sh

# 开始安装，并保存日志
if [ -s /root/ltnmp-install.log ] ; then
    mv -f /root/ltnmp-install.log /root/ltnmp-install.log.ltnmp
fi
install 2>&1 | tee -a /root/ltnmp-install.log
