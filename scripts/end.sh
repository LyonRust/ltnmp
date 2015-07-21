#!/bin/bash

# 安装结束需要的操作
end_system()
{
    # 安装结束还原系统某些组件
    replace_autoconf
    replace_curl

    # 添加防火墙规则
    add_iptables_rule

    # 开启服务
    ltnmp_startup
}

# 安装完PHP后需要做的一些事情
after_install_php()
{

    echo "复制opcache控制面板到web目录下..."
    cp ${current_dir}/lib/conf/ocp.php /home/www/default/

    echo "安装探针..."
    cp ${current_dir}/lib/conf/ocp.php /home/www/default/

    echo "复制默认站点首页文件..."
    cp ${current_dir}/lib/conf/index.html /home/www/default/index.html
    cp ${current_dir}/lib/conf/ltnmp.gif /home/www/default/ltnmp.gif

}

# 添加防火墙规则
add_iptables_rule()
{
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 1 -i lo -j ACCEPT
        /sbin/iptables -I INPUT 2 -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -I INPUT 3 -p tcp --dport 80 -j ACCEPT
        /sbin/iptables -I INPUT 4 -p tcp -s 127.0.0.1 --dport 3306 -j ACCEPT
        /sbin/iptables -I INPUT 5 -p tcp --dport 3306 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
            cat >/etc/network/if-post-down.d/iptables<<EOF
#!/bin/bash
iptables-save > /etc/iptables.rules
EOF
            chmod +x /etc/network/if-post-down.d/iptables
            cat >/etc/network/if-pre-up.d/iptables<<EOF
#!/bin/bash
iptables-restore < /etc/iptables.rules
EOF
            chmod +x /etc/network/if-pre-up.d/iptables
        fi
    fi
}

ltnmp_startup()
{
    echo "添加启动服务并启动ltnmp..."
    cp ${current_dir}/lib/conf/ltnmp /bin/ltnmp
    chmod +x /bin/ltnmp
    echo "启动Tengine..."
    /etc/init.d/nginx start
    echo "启动mariadb..."
    /etc/init.d/mariadb start
    echo "启动php..."
    /etc/init.d/php-fpm start
}
