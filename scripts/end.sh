#!/bin/bash

# 安装结束需要的操作
end_system() {
    # 安装结束还原系统某些组件
    #replace_autoconf
    #replace_curl

    # 添加防火墙规则
    add_iptables_rule

    # 开启服务
    ltnmp_startup

    # 增加开机启动
    bootstart

    # 增加虚拟主机控制脚本
    ltnmp_vhost

    # 最后的检查，成功或者失败的显示信息
    ltnmp_end
}

# 安装完PHP后需要做的一些事情
after_install_php() {

    echo "Copy opcache Control Cpanl..."
    cp ${current_dir}/lib/conf/ocp.php /home/www/default/

    echo "Copy p.php..."
    cp ${current_dir}/lib/conf/p.php /home/www/default/

    echo "Copy default files..."
    cp ${current_dir}/lib/conf/index.html /home/www/default/index.html
    cp ${current_dir}/lib/conf/ltnmp.gif /home/www/default/ltnmp.gif

}

# 添加防火墙规则
add_iptables_rule() {
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT 1 -i lo -j ACCEPT
        /sbin/iptables -I INPUT 2 -m state --state ESTABLISHED,RELATED -j ACCEPT
        /sbin/iptables -I INPUT 3 -p tcp --dport 80 -j ACCEPT
        /sbin/iptables -I INPUT 4 -p tcp -s 127.0.0.1 --dport 3306 -j ACCEPT
        /sbin/iptables -I INPUT 5 -p tcp --dport 3306 -j DROP
        if [ "${ANDY}" = "CentOS" ]; then
            service iptables save
        elif [ "${ANDY}" = "Ubuntu" ]; then
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

ltnmp_startup() {
    echo "Change web root Access"
    chown -R www:www /home/www/default
    echo "Add and Start ltnmp..."
    cp ${current_dir}/lib/conf/ltnmp /bin/ltnmp
    chmod +x /bin/ltnmp
    echo "Start Tengine..."
    /etc/init.d/nginx start
    echo "Start mariadb..."
    /etc/init.d/mariadb start
    echo "Start php..."
    /etc/init.d/php-fpm start
}

bootstart() {
    # 添加Tengine
    chkconfig nginx on
    # 添加php
    chkconfig php-fpm on
    # 添加mysql
    chkconfig mysql on
}

ltnmp_vhost() {
    echo "Copy ltnmp..."
    cp ${current_dir}/lib/conf/ltnmp /root/
    chmod u+x /root/ltnmp
    ln -s /root/ltnmp /bin/ltnmp
}

ltnmp_end() {
    clear
    isnginx=""
    ismysql=""
    isphp=""
    echo "Checking..."
    if [ -s /usr/local/nginx ] && [ -s /usr/local/nginx/sbin/nginx ]; then
      echo "Nginx: OK"
      isnginx="ok"
      else
      echo "Error: /usr/local/nginx not found!!!Nginx install failed."
    fi

    if [ -s /usr/local/php/sbin/php-fpm ] && [ -s /usr/local/php/etc/php.ini ] && [ -s /usr/local/php/bin/php ]; then
      echo "PHP: OK"
      echo "PHP-FPM: OK"
      isphp="ok"
      else
      echo "Error: /usr/local/php not found!!!PHP install failed."
    fi

    if [ -s /usr/local/mysql ] && [ -s /usr/local/mysql/bin/mysql ]; then
      echo "mysql: OK"
      ismysql="ok"
      else
      echo "Error: /usr/local/mysql not found!!!mysql install failed."
    fi
    if [ "${isnginx}" = "ok" ] && [ "${ismysql}" = "ok" ] && [ "${isphp}" = "ok" ]; then
        clear
        echo "--------------------------------------------------------"
        echo ""
        echo "     ltnmp v${ltnmp_version} for ${DISTRO} Linux Server"
        echo ""
        echo "     Automatic compilation(Tengine/nginx)+php+(Mariadb/Mysql)"
        echo ""
        echo "     By:Andy http://www.moqifei.com"
        echo ""
        echo "--------------------------------------------------------"
        echo ""
        echo "ltnmp is install OK"
        echo "Usage: ltnmp {start|stop|reload|restart|kill|status}"
        echo "Usage: ltnmp {nginx|mysql|php} {start|stop|reload|restart|kill|status}"
        echo "Usage: ltnmp vhost {add|list|del}"
        echo ""
        /etc/init.d/nginx status
        /etc/init.d/php-fpm status
        /etc/init.d/mysql status
    else
        echo "Sorry,Failed to install LTNMP!"
        echo "Please visit http://www.moqifei.com/ltnmp feedback errors and logs."
        echo "You can download /root/ltnmp-install.log from your server,and upload ltnmp-install.log to LTNMP Forum."
    fi
}
