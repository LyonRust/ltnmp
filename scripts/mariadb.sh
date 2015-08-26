#!/bin/bash

install_mariadb() {
    echo "--------------------------------------------"
    echo ""
    echo "     Install ${ltnmp_mariadb}"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    rm -f /etc/my.cnf

    cd ${current_dir}/src
    tar -zxvf ${ltnmp_mariadb}.tar.gz
    cd ${ltnmp_mariadb}

    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DSYSCONFDIR=/etc -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_unicode_ci -DWITH_READLINE=1 -DWITH_SSL=bundled -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make && make install


    if [ "${custorm_db_data_dir}" = "n" ]; then
        custorm_db_data_dir="/usr/local/mysql/data"
    fi

    cp ./support-files/my-medium.cnf /etc/my.cnf
    sed "/skip-external-locking/i\pid-file = ${custorm_db_data_dir}/mysql.pid" -i /etc/my.cnf
    sed "/skip-external-locking/i\log_error = ${custorm_db_data_dir}/mysql.err" -i /etc/my.cnf
    sed '/skip-external-locking/i\basedir = /usr/local/mysql' -i /etc/my.cnf
    sed "/skip-external-locking/i\datadir = ${custorm_db_data_dir}" -i /etc/my.cnf
    sed '/skip-external-locking/i\user = mysql' -i /etc/my.cnf
    if [ "${install_innodb}" = "y" ]; then
        sed '/skip-external-locking/i\innodb_file_per_table = 1' -i /etc/my.cnf
        sed -i 's:#innodb:innodb:g' /etc/my.cnf
        sed -i "s:/usr/local/mysql/data:${custorm_db_data_dir}:g" /etc/my.cnf
    else
        sed '/skip-external-locking/i\default-storage-engine=MyISAM\nloose-skip-innodb' -i /etc/my.cnf
    fi

    mkdir -p ${custorm_db_data_dir}
    /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=${custorm_db_data_dir} --user=mysql
    chown -R mysql ${custorm_db_data_dir}


    chgrp -R mysql /usr/local/mysql/
    cp ./support-files/mysql.server /etc/init.d/mysql

    chmod 755 /etc/init.d/mysql

    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
    ldconfig

    ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
    ln -s /usr/local/mysql/include/mysql /usr/include/mysql
    if [ -d "/proc/vz" ];then
        ulimit -s unlimited
    fi
    /etc/init.d/mysql start

    ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
    ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
    ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
    ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

    /usr/local/mysql/bin/mysqladmin -u root password ${mysql_root_pwd}

    cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('${mysql_root_pwd}') where user='root';
delete from user where not (user='root');
delete from user where user='root' and password='';
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

    /usr/local/mysql/bin/mysql -u root -p$mysql_root_pwd -h localhost < /tmp/mysql_sec_script

    rm -f /tmp/mysql_sec_script

    echo -e "\nexpire_logs_days = 10" >> /etc/my.cnf
    sed -i '/skip-external-locking/a\max_connections = 1000' /etc/my.cnf

    /etc/init.d/mysql restart
    /etc/init.d/mysql stop

}
