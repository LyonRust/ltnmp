#!/bin/bash

run() {
    ## 检测Linux发行版
    get_linux_distro

    ## 检测系统32/64位
    get_os_bit
}

## 获取Linux发行版，支持(Centos,Red Hat,Ubuntu,Aliyun,Fedora,Debian,Raspbian)
get_linux_distro() {
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

## 检测系统32/64位
get_os_bit() {
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        is_64bit='y'
    else
        is_64bit='n'
    fi
}

## -----------------------------------------------------------------------------
## 第一步，选择要安装的组件
install() {
    # 初始化安装组件标记
    ltnmp_flag_webserver=""
    ltnmp_flag_php="n"
    ltnmp_flag_db=""
    ltnmp_flag_phpmyadmin="n"

    echo "  ltnmp v${ltnmp_version} module include ${ltnmp_tengine}, ${ltnmp_nginx}, ${ltnmp_php}, ${ltnmp_mariadb}, ${ltnmp_mysql}, ${ltnmp_phpmyadmin}"
    echo ""
    echo "  1: tengine+php+mariadb(Automatic compilation)"
    echo "  2: tengine(only)     3: nginx(only)     4: php(only)"
    echo "  5: mariadb(only)     6: mysql(only)     7: phpmyadmin(only)"

    read -p ">>Enter your choose number (or exit): " action

    case "${action}" in
        1 )
            # 初始化工作
            dispaly_selection
        ;;
        2 )
            # 安装tengine
            ltnmp_flag_webserver="tengine"
        ;;
        3 )
            # 安装nginx
            ltnmp_flag_webserver="nginx"
        ;;
        4 )
            # 安装php
            ltnmp_flag_php="y"
        ;;
        5 )
            # 安装mariadb
            init_db
            init_innodb
            init_dbpath
            ltnmp_flag_db="mariadb"
        ;;
        6 )
            # 安装mysql
            init_db
            init_innodb
            init_dbpath
            ltnmp_flag_db="mysql"
        ;;
        7 )
            # 安装phpmyadmin
            ltnmp_flag_phpmyadmin="y"
        ;;
        * )
            exit 1
        ;;
    esac

    # 系统环境
    init_system

    # 安装mariadb/mysql
    if [ "${ltnmp_flag_db}" == "mariadb" ] ; then
        install_mariadb
    elif [ "${ltnmp_flag_db}" == "mysql" ] ; then
        install_mysql
    fi
    # 安装php
    if [ "${ltnmp_flag_php}" == "y" ] ; then
        install_php
    fi
    # 安装phpmyadmin
    if [ "${ltnmp_flag_phpmyadmin}" == "y" ] ; then
        install_phpmyadmin
    fi
    # 安装tengine/nginx
    if [ "${ltnmp_flag_webserver}" == "tengine" ] ; then
        install_tengine
    elif [ "${ltnmp_flag_webserver}" == "mysql" ] ; then
        install_nginx
    fi

    # 完成工作
    case "${action}" in
        1 )
            # 系统组件还原
            end_system
        ;;
        2|3 )
            add_startup nginx
            echo "Start Tengine/Nginx..."
            /etc/init.d/nginx start
        ;;
        4 )
            # 添加php
            add_startup php-fpm
            echo "Start php..."
            /etc/init.d/php-fpm start
        ;;
        5|6 )
            add_startup mysql
            echo "Start mysql..."
            /etc/init.d/mysql start
        ;;
        7 )
            echo "phpmyadmin installed ok"
        ;;
        * )
            exit 1
        ;;
    esac

}

## 组件检测，依赖，用户等
init_system() {
    # 系统编译组件检测、安装
    check_system
    # 安装系统组件/依赖
    install_system_dependence
    # 添加用户(组)
    add_user
}

## 数据库配置
init_db() {
    mysql_root_pwd="root"
    echo "Set database password"
    read -p "Please enter(Default:root): " mysql_root_pwd
    if [ "${mysql_root_pwd}" = "" ]; then
        mysql_root_pwd="root"
    fi
    echo "The root database password is: ${mysql_root_pwd}"
}

## 开启/关闭InnoDB存储引擎
init_innodb() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Enable/Disable InnoDB Storage Engine"
    read -p "Enter y/n(Default:y): " install_innodb

    case "${install_innodb}" in
    [yY][eE][sS]|[yY])
        echo "enable InnoDB Storage Engine"
        install_innodb="y"
    ;;
    [nN][oO]|[nN])
        echo "disable InnoDB Storage Engine"
        install_innodb="n"
    ;;
    *)
        echo "enable InnoDB Storage Engine"
        install_innodb="y"
    esac
}

## 自定义数据库存储位置，自定义路径为一个绝对路径
init_dbpath() {
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Custom database file path(Default:/usr/local/mysql/data)"
    read -p "Please enter a custom path(absolute path): " custorm_db_data_dir
    if [ "${custorm_db_data_dir}" = "" ] ; then
        custorm_db_data_dir="n"
        echo "Database default path:/usr/local/mysql/data"
    else

        # 检测是否是绝对路径
        if echo ${custorm_db_data_dir}|grep -qe '^/' ; then
            mkdir -p ${custorm_db_data_dir}
            echo "Custom database file path:${custorm_db_data_dir}"
        else
            custorm_db_data_dir="n"
            echo "Your input is not legal."
            echo "Use default path:/usr/local/mysql/data"
        fi

    fi
}

## 初始化工作
dispaly_selection() {
    # 安装组件标记调整
    ltnmp_flag_php="y"
    ltnmp_flag_phpmyadmin="y"

    ## 第一步：初始化数据库
    init_db

    ## 第二步：安装mariadb或者mysql
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Install ${ltnmp_mariadb},Please input y or press Enter"
    echo "Install ${ltnmp_mysql},Please input n"
    read -p "Enter y/n(Default:y): " ltnmp_flag_db
    case "${ltnmp_flag_db}" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
        echo "Install ${ltnmp_mariadb}"
        ltnmp_flag_db="mariadb"
    ;;
    n|N|No|NO|no|nO)
        echo "Install ${ltnmp_mysql}"
        ltnmp_flag_db="mysql"
    ;;
    *)
        echo "Install ${ltnmp_mariadb}"
        ltnmp_flag_db="mariadb"
    esac

    ## 第三步：开启/关闭InnoDB存储引擎
    init_innodb

    ## 第四步：自定义数据库存储位置，自定义路径为一个绝对路径
    init_dbpath

    ## 第五步：选择tengine或者nginx
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "Install ${ltnmp_tengine},Please input y or press Enter"
    echo "Install ${ltnmp_nginx},Please input n"
    read -p "Enter y/n(Default:y): " ltnmp_flag_webserver
    case "${ltnmp_flag_webserver}" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS)
        echo "Install ${ltnmp_tengine}"
        ltnmp_flag_webserver="tengine"
    ;;
    n|N|No|NO|no|nO)
        echo "Install ${ltnmp_nginx}"
        ltnmp_flag_webserver="nginx"
    ;;
    *)
        echo "Install ${ltnmp_tengine}"
        ltnmp_flag_webserver="tengine"
    esac

    echo ""

    sleep 1
}

## 添加www用户和用户组，用于web服务和php
add_user() {
    ## 数据库用户(组)
    groupadd mysql
    useradd -s /sbin/nologin -g mysql mysql

    ## web/php用户(组)
    groupadd www
    useradd -s /sbin/nologin -g www www

    ## 创建web默认站点和日志文件夹
    mkdir -p /home/www/default
    chmod +w /home/www/default
    mkdir -p /home/www/wwwlogs
    chmod 777 /home/www/wwwlogs
}

install_autoconf() {
    echo -e "\n==========autoconf install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_autoconf}.tar.gz
    cd ${ltnmp_autoconf}
    ./configure --prefix=/usr/local/${ltnmp_autoconf}
    make && make install

    ## replace system autoconf
    #replace_autoconf="n"
    #if [ -s /usr/bin/autoconf ] ; then
    #    mv /usr/bin/autoconf /usr/bin/autoconf.ltnmp
    #    replace_autoconf="y"
    #fi
    #ln -s /usr/local/${ltnmp_autoconf}/bin/autoconf /usr/bin/autoconf

    #ldconfig
    cd ${current_dir}
}

replace_autoconf() {
    if [ "${replace_autoconf}" = "y" ] ; then
        mv /usr/bin/autoconf /usr/bin/autoconf.ltnmp.bak
        mv /usr/bin/autoconf.ltnmp /usr/bin/autoconf
    fi
}

install_curl() {
    echo -e "\n==========curl install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_curl}.tar.gz
    cd ${ltnmp_curl}
    ./configure --prefix=/usr/local/curl --enable-ares
    make && make install

    #$ replace system autoconf
    #replace_curl="n"
    #if [ -s /usr/bin/curl ] ; then
    #    mv /usr/bin/curl /usr/bin/curl.ltnmp
    #    replace_curl="y"
    #fi
    #ln -s /usr/local/${ltnmp_curl}/bin/curl /usr/bin/curl

    #ldconfig
    cd ${current_dir}
}

replace_curl() {
    if [ "${replace_curl}" = "y" ] ; then
        mv /usr/bin/curl /usr/bin/curl.ltnmp.bak
        mv /usr/bin/curl.ltnmp /usr/bin/curl
    fi
}

install_freetype() {
    echo -e "\n==========freetype install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_freetype}.tar.gz
    cd ${ltnmp_freetype}
    ./configure --prefix=/usr/local/freetype
    make && make install

    echo "/usr/local/freetype/lib" > /etc/ld.so.conf.d/freetype.conf

    ln -sf /usr/local/freetype/include/freetype2 /usr/local/include
    #ln -sf /usr/local/freetype/include/ft2build.h /usr/local/include

    ldconfig
    cd ${current_dir}
}

install_jemalloc() {
    echo -e "\n==========jemalloc install==========\n"

    cd ${current_dir}/src/base
    tar -jxvf ${ltnmp_jemalloc}.tar.bz2
    cd ${ltnmp_jemalloc}
    ./configure
    make && make install

    echo "/usr/local/lib" > /etc/ld.so.conf.d/jemalloc.conf

    ldconfig
    cd ${current_dir}
}

install_libiconv() {
    echo -e "\n==========libiconv install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_libiconv}.tar.gz
    cd ${ltnmp_libiconv}
    patch -p0 < ${current_dir}/lib/patch/${ltnmp_libiconv_glibc}.patch
    ./configure --enable-static
    make && make install

    ldconfig
    cd ${current_dir}
}

install_libmcrypt() {
    echo -e "\n==========libmcrypt install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_libmcrypt}.tar.gz
    cd ${ltnmp_libmcrypt}
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

install_mhash() {
    echo -e "\n==========mhash install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_mhash}.tar.gz
    cd ${ltnmp_mhash}
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

install_mcrypt() {
    # 依赖mhash大于0.8.15组件
    echo -e "\n==========mcrypt install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_mcrypt}.tar.gz
    cd ${ltnmp_mcrypt}
    ./configure
    make && make install

    ldconfig
    cd ${current_dir}
}

install_pcre() {
    echo -e "\n==========pcre install==========\n"

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_pcre}.tar.gz
    cd ${ltnmp_pcre}
    ./configure --enable-utf8
    make && make install

    ldconfig
    cd ${current_dir}
}

install_cmake() {
    echo -e "\n==========cmake install==========\n"

    if [ -s /usr/bin/cmake ] ; then
        mv -r /usr/bin/cmake /usr/bin/cmake.ltnmp
    fi

    cd ${current_dir}/src/base
    tar -zxvf ${ltnmp_cmake}.tar.gz
    cd ${ltnmp_cmake}
    ./bootstrap
    make && make install
    ln -s /usr/local/bin/cmake /usr/bin/cmake
}

## 安装系统组件/依赖
install_system_dependence() {
    ## 安装系统依赖
    ## 就是上面几个函数
    ## 需要本地磁盘空间，共享目录有些组件安装不成功
    install_autoconf
    install_curl
    install_freetype
    install_jemalloc
    install_libiconv
    install_libmcrypt
    ## mcrypt依赖mhash大于0.8.15组件,所以先安装mhash
    install_mhash
    install_mcrypt
    install_pcre
    install_cmake
}

restart_nginx() {
    if [ -s /etc/init.d/nginx ] ; then
        nginx_status=`/etc/init.d/nginx status`
        if echo "${nginx_status}" | grep -q 'running' ; then
            /etc/init.d/nginx restart
        else
            /etc/init.d/nginx start
        fi
    fi
}

restart_php() {
    if [ -s /etc/init.d/php-fpm ] ; then
        php_status=`/etc/init.d/php-fpm status`
        if echo "${php_status}" | grep -q 'running' ; then
            /etc/init.d/php-fpm restart
        else
            /etc/init.d/php-fpm start
        fi
    fi
}

restart_mysql() {
    if [ -s /etc/init.d/mysql ] ; then
        mysql_status=`/etc/init.d/mysql status`
        if echo "${mysql_status}" | grep -q 'running' ; then
            /etc/init.d/mysql restart
        else
            /etc/init.d/mysql start
        fi
    fi
}

check_db() {
    if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        mysql_bin="/usr/local/mariadb/bin/mysql"
        mysql_config="/usr/local/mariadb/bin/mysql_config"
        mysql_dir="/usr/local/mariadb"
        is_mysql="n"
        db_name="mariadb"
    else
        mysql_bin="/usr/local/mysql/bin/mysql"
        mysql_config="/usr/local/mysql/bin/mysql_config"
        mysql_dir="/usr/local/mysql"
        is_mysql="y"
        db_name="mysql"
    fi
}

add_startup() {
    param=$1
    echo "Add ${param} service at system startup..."
    if [ "${PM}" = "yum" ]; then
        chkconfig --add ${param}
        chkconfig ${param} on
    elif [ "${PM}" = "apt" ]; then
        update-rc.d -f ${param} defaults
    fi
}

remove_startup() {
    param=$1
    echo "Removing ${param} service at system startup..."
    if [ "${PM}" = "yum" ]; then
        chkconfig ${param} off
        chkconfig --del ${param}
    elif [ "${PM}" = "apt" ]; then
        update-rc.d -f ${param} remove
    fi
}
