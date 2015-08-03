#!/bin/bash

install_composer() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall composer-1.0-dev"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    ## 检测当前目录是否存在composer.phar文件，不存在则从服务器上下载
    ## 安装到全局/usr/local/bin/composer
    if [ -s composer.phar ]; then
        cp -r composer.phar /usr/local/bin/composer
    else
        echo "Get the latest Composer version ..."
        curl -sS https://getcomposer.org/installer | php
        cp -r composer.phar /usr/local/bin/composer
    fi

    echo "composer installed successfully!"
    echo "The install-dir:/usr/local/bin/composer"

}