#!/bin/bash

run()
{
    # 检测Linux发行版
    get_linux_distro

    # 检测系统32/64位
    get_os_bit
}

# 获取Linux发行版，支持(Centos,Red Hat,Ubuntu,Aliyun,Fedora,Debian,Raspbian)
get_linux_distro()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
        ANDY='CentOS'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
        ANDY='CentOS'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        ANDY='CentOS'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
        ANDY='CentOS'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
        ANDY='Ubuntu'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
        ANDY='Ubuntu'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
        ANDY='Ubuntu'
    else
        DISTRO='unknow'
        ANDY='unknow'
    fi
}

# 检测系统32/64位
get_os_bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        is_64bit='y'
    else
        is_64bit='n'
    fi
}

# 初始化工作
dispaly_selection()
{
    mysql_root_pwd="root"
    echo "Set database password"
    read -p "Please enter(Default:root): " mysql_root_pwd
    if [ "${mysql_root_pwd}" = "" ]; then
        mysql_root_pwd="root"
    fi
    echo "The root database password is: ${mysql_root_pwd}"

    #开启/关闭InnoDB存储引擎
    echo "==========================="

    install_innodb="y"
    echo "Enable/Disable InnoDB Storage Engine"
    read -p "Enter y/n(Default:y):" install_innodb

    case "${install_innodb}" in
    [yY][eE][sS]|[yY])
        echo "enable InnoDB Storage Engine"
    ;;
    [nN][oO]|[nN])
        echo "disable InnoDB Storage Engine"
    ;;
    *)
        echo "enable InnoDB Storage Engine"
        install_innodb="y"
    esac

    # 自定义数据库存储位置
    echo "==========================="
    custorm_db_data_dir="n"
    echo "Custom database file path(Default:Database default path)"
    read -p "Please enter a custom path: " custorm_db_data_dir
    if [ "${custorm_db_data_dir}" = "" ] ; then
        custorm_db_data_dir="n"
        echo "Database default path"
    else
        mkdir -p $custorm_db_data_dir
        echo "Custom database file path:${custorm_db_data_dir}"
    fi

    # 选择Tengine/Nginx
    echo "==========================="
    install_tengine="y"
    echo "Install Tengine-2.1.0,Please input y or press Enter"
    echo "Install Nginx-1.9.3,Please input n"
    read -p "Enter y/n(Default:y):" install_tengine
    case "${install_tengine}" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
        echo "Install Tengine-2.1.0"
        install_tengine="y"
    ;;
    n|N|No|NO|no|nO)
        echo "Install Nginx-1.9.3"
        install_tengine="n"
    ;;
    *)
        echo "Install Tengine-2.1.0"
        install_tengine="y"
    esac
}

# 添加www用户和用户组，用于web服务和php
add_user()
{
    # 数据库用户(组)
    groupadd mysql
    useradd -s /sbin/nologin -g mysql mysql

    # web/php用户(组)
    groupadd www
    useradd -s /sbin/nologin -g www www

    mkdir -p /home/www/default
    chmod +w /home/www/default
    mkdir -p /home/www/wwwlogs
    chmod 777 /home/www/wwwlogs
}

install_autoconf()
{
    echo "==========autoconf install=========="

    cd ${current_dir}/src/base
    tar -zxvf autoconf-2.13.tar.gz
    cd autoconf-2.13
    ./configure --prefix=/usr/local/autoconf-2.13
    make && make install

    # replace system autoconf
    #replace_autoconf="n"
    #if [ -s /usr/bin/autoconf ] ; then
    #    mv /usr/bin/autoconf /usr/bin/autoconf.ltnmp
    #    replace_autoconf="y"
    #fi
    #ln -s /usr/local/autoconf-2.13/bin/autoconf /usr/bin/autoconf

    #ldconfig
    cd ${current_dir}
}

replace_autoconf()
{
    if [ "${replace_autoconf}" = "y" ] ; then
        mv /usr/bin/autoconf /usr/bin/autoconf.ltnmp.bak
        mv /usr/bin/autoconf.ltnmp /usr/bin/autoconf
    fi
}

install_curl()
{
    echo "==========curl install=========="

    cd ${current_dir}/src/base
    tar -zxvf curl-7.42.1.tar.gz
    cd curl-7.42.1
    ./configure --prefix=/usr/local/curl --enable-ares
    make && make install

    # replace system autoconf
    #replace_curl="n"
    #if [ -s /usr/bin/curl ] ; then
    #    mv /usr/bin/curl /usr/bin/curl.ltnmp
    #    replace_curl="y"
    #fi
    #ln -s /usr/local/curl-7.42.1/bin/curl /usr/bin/curl

    #ldconfig
    cd ${current_dir}
}

replace_curl()
{
    if [ "${replace_curl}" = "y" ] ; then
        mv /usr/bin/curl /usr/bin/curl.ltnmp.bak
        mv /usr/bin/curl.ltnmp /usr/bin/curl
    fi
}

install_freetype()
{
    echo "==========freetype install=========="

    cd ${current_dir}/src/base
    tar -zxvf freetype-2.6.tar.gz
    cd freetype-2.6
    ./configure --prefix=/usr/local/freetype
    make && make install

    echo "/usr/local/freetype/lib" > /etc/ld.so.conf.d/freetype.conf

    ln -sf /usr/local/freetype/include/freetype2 /usr/local/include
    #ln -sf /usr/local/freetype/include/ft2build.h /usr/local/include

    ldconfig
    cd ${current_dir}
}

install_jemalloc()
{
    echo "==========jemalloc install=========="

    cd ${current_dir}/src/base
    tar -jxvf jemalloc-3.6.0.tar.bz2
    cd jemalloc-3.6.0
    ./configure
    make && make install

    echo "/usr/local/lib" > /etc/ld.so.conf.d/jemalloc.conf

    ldconfig
    cd ${current_dir}
}

install_libiconv()
{
    echo "==========libiconv install=========="

    cd ${current_dir}/src/base
    tar -zxvf libiconv-1.14.tar.gz
    cd libiconv-1.14
    patch -p0 < ${current_dir}/src/patch/libiconv-glibc-2.16.patch
    ./configure --enable-static
    make && make install

    ldconfig
    cd ${current_dir}
}

install_libmcrypt()
{
    echo "==========libmcrypt install=========="

    cd ${current_dir}/src/base
    tar -zxvf libmcrypt-2.5.8.tar.gz
    cd libmcrypt-2.5.8
    ./configure
    make && make install

    ldconfig

    cd libltdl/
    ./configure --enable-ltdl-install
    make && make install
    ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
    ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
    ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
    ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8

    ldconfig
    cd ${current_dir}
}

install_mhash()
{
    echo "==========mhash install=========="

    cd ${current_dir}/src/base
    tar -zxvf mhash-0.9.9.9.tar.gz
    cd mhash-0.9.9.9
    ./configure
    make && make install

    ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
    ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
    ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
    ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
    ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

    ldconfig
    cd ${current_dir}
}

install_mcrypt()
{
    # 依赖mhash大于0.8.15组件
    echo "==========mcrypt install=========="

    cd ${current_dir}/src/base
    tar -zxvf mcrypt-2.6.8.tar.gz
    cd mcrypt-2.6.8
    ./configure
    make && make install

    ldconfig
    cd ${current_dir}
}

install_pcre()
{
    echo "==========pcre install=========="

    cd ${current_dir}/src/base
    tar -zxvf pcre-8.36.tar.gz
    cd pcre-8.36
    ./configure
    make && make install

    ldconfig
    cd ${current_dir}
}

# 安装系统组件/依赖
install_system_dependence()
{
    # 安装系统依赖
    # 就是上面几个函数
    # 需要本地磁盘空间，共享目录有些主键安装不成功
    install_autoconf
    install_curl
    install_freetype
    install_jemalloc
    install_libiconv
    install_libmcrypt
    #mcrypt依赖mhash大于0.8.15组件,所以先安装mhash
    install_mhash
    install_mcrypt
    install_pcre
}

echo_yellow()
{
  echo $(color_text "$1" "33")
}

color_text()
{
  echo -e " \e[0;$2m$1\e[0m"
}
