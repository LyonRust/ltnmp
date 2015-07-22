#!/bin/bash

install_phpmyadmin()
{
    echo "--------------------------------------------"
    echo ""
    echo "     Install PhpMyAdmin-4.4.12"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf phpMyAdmin-4.4.12-all-languages.tar.gz
    mv phpMyAdmin-4.4.12-all-languages /home/www/default/phpmyadmin

    cp ${current_dir}/lib/conf/config.inc.php /home/www/default/phpmyadmin/
    sed -i 's/ANDYMOQIFEI/Andy'$RANDOM'Moqifei/g' /home/www/default/phpmyadmin/config.inc.php
    chmod -R 755 /home/www/default/phpmyadmin/
    chown -R www:www /home/www/default/phpmyadmin/

}