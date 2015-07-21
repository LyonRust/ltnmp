#!/bin/bash

install_phpmyadmin()
{
    echo_yellow "--------------------------------------------"
    echo ""
    echo_yellow "     安装PhpMyAdmin-4.4.12"
    echo ""
    echo_yellow "     By:安迪(Andy) http://www.moqifei.com"
    echo ""
    echo_yellow "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf phpMyAdmin-4.4.12-all-languages.tar.gz
    mv phpMyAdmin-4.4.12-all-languages /home/www/default/phpmyadmin

    cp ${current_dir}/lib/conf/config.inc.php /home/www/default/phpmyadmin/
    sed -i 's/ANDYMOQIFEI/Andy'$RANDOM'Moqifei/g' /home/www/default/phpmyadmin/config.inc.php
    chmod -R 755 /home/www/default/phpmyadmin/
    chown -R www:www /home/www/default/phpmyadmin/

}