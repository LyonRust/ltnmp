#!/bin/bash

install_mariadb10()
{
    echo_yellow "--------------------------------------------"
    echo ""
    echo_yellow "     安装MariaDb 10"
    echo ""
    echo_yellow "     By:安迪(Andy) http://www.moqifei.com"
    echo ""
    echo_yellow "--------------------------------------------"

    rm -f /etc/my.cnf

    cd ${current_dir}/src
    tar -zxvf mariadb-10.0.20.tar.gz
    cd mariadb-10.0.20

    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DSYSCONFDIR=/etc -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install

    cp ./support-files/my-medium.cnf /etc/my.cnf
    if [ $installinnodb = "y" ]; then
        sed -i 's:#innodb:innodb:g' /etc/my.cnf
    else
        sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    chown -R mysql:mysql /usr/local/mariadb

    /usr/local/mariadb/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mariadb --datadir=/usr/local/mariadb/var --user=mysql

    chown -R mysql:mysql /usr/local/mariadb
    cp ./support-files/mysql.server /etc/init.d/mariadb

    sed -i 's:^basedir=$:basedir=/usr/local/mariadb:g' /etc/init.d/mariadb
    sed -i 's:^datadir=$:datadir=/usr/local/mariadb/var:g' /etc/init.d/mariadb

    chmod u+x /etc/init.d/mariadb

    cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
    /usr/local/mariadb/lib
    /usr/local/lib
EOF
    ldconfig

    ln -s /usr/local/mariadb/lib/mysql /usr/lib/mysql
    ln -s /usr/local/mariadb/include/mysql /usr/include/mysql
    if [ -d "/proc/vz" ];then
        ulimit -s unlimited
    fi
    /etc/init.d/mariadb start

    ln -s /usr/local/mariadb/bin/mysql /usr/bin/mysql
    ln -s /usr/local/mariadb/bin/mysqldump /usr/bin/mysqldump
    ln -s /usr/local/mariadb/bin/myisamchk /usr/bin/myisamchk
    ln -s /usr/local/mariadb/bin/mysqld_safe /usr/bin/mysqld_safe

    /usr/local/mariadb/bin/mysqladmin -u root password ${mysql_root_pwd}

    cat > /tmp/mariadb_sec_script<<EOF
    use mysql;
    update user set password=password('${mysql_root_pwd}') where user='root';
    delete from user where not (user='root') ;
    delete from user where user='root' and password='';
    drop database test;
    DROP USER ''@'%';
    flush privileges;
EOF

    /usr/local/mariadb/bin/mysql -u root -p${mysql_root_pwd} -h localhost < /tmp/mariadb_sec_script

    rm -f /tmp/mariadb_sec_script

    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf

    /etc/init.d/mariadb restart
    /etc/init.d/mariadb stop

}
