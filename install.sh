#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## ltnmp一键安装包
## 安装Tengine/Nginx,PHP,Maraidb/Mysql.
## by 安迪(Andy) (http://www.moqifei.com)

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi

# 当前路径
current_dir=$(pwd)

# ltnmp版本号
ltnmp_version='2.0'

# 加载初始化脚本
. scripts/bootstrap.sh

## 检测系统参数
run 2>&1 | tee /root/ltnmp-install.log

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "无法获取该操作系统的发行版本，或者不支持该系统发行版本"
    exit 1
fi

clear

echo "-------------------------------------------------------------------------"
echo ""
echo_yellow "     ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
echo ""
echo_yellow "     一键自动编译(Tengine/nginx)+php+(Mariadb/Mysql)"
echo ""
echo_yellow "     By:安迪(Andy) http://www.moqifei.com"
echo ""
echo "-------------------------------------------------------------------------"


## 加载各个发行版，数据库，PHP，web服务器等脚本
. scripts/${SCRIPT}.sh
. scripts/mariadb.sh
. scripts/tengine.sh
. scripts/nginx.sh
. scripts/php.sh
. scripts/phpmyadmin.sh
. scripts/end.sh

# 开始安装，并保存日志
install 2>&1 | tee -a /root/ltnmp-install.log
