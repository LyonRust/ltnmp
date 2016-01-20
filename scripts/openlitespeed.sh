#!/bin/bash

install_openlitespeed() {
    echo "--------------------------------------------"
    echo ""
    echo "     Indtall ${ltnmp_openlitespeed}"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    ## 设置管理员名称
    read -p ">>Set administrator user name(default:admin): " admin_name
    if [ "${admin_name}" == "" ] ; then
        admin_name="admin"
    fi
    echo "administrator name is: " admin_name

    ## 设置管理员密码
    read -p ">>Set password of administrator(default:123456): " admin_passwd
    if [ "${admin_passwd}" == "" ] ; then
        admin_passwd="123456"
    fi
    echo "administrator passwoed is: " admin_passwd

    ## 设置管理员邮箱
    read -p ">>Set email of administrator(default:root@localhost): " admin_email
    if [ "${admin_email}" == "" ] ; then
        admin_email="root@localhost"
    fi
    echo "administrator Email is: " admin_email

    cd ${current_dir}/src
    tar -zxvf ${ltnmp_openlitespeed}.tgz
    cd ${ltnmp_openlitespeed}
    ./configure --with-user=www --with-group=www --with-admin="${admin_name}" --with-password="${admin_passwd}" --with-email="${admin_email}" --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_gzip_static_module --with-ipv6 --with-ld-opt="-ljemalloc"
    make && make install

    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

    mkdir -p /usr/local/nginx/conf/vhost

    cp ${current_dir}/lib/init.d/nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx

    # 配置文件调整
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.ltnmp
    cp ${current_dir}/lib/conf/*.conf /usr/local/nginx/conf/
    cp ${current_dir}/lib/rewrite/* /usr/local/nginx/conf/
}