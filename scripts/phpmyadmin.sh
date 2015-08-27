#!/bin/bash

install_phpmyadmin() {
    echo "--------------------------------------------"
    echo ""
    echo "     Install ${ltnmp_phpmyadmin}"
    echo ""
    echo "     By:Andy http://www.moqifei.com"
    echo ""
    echo "--------------------------------------------"

    cd ${current_dir}/src
    tar -zxvf ${ltnmp_phpmyadmin}.tar.gz
    mv ${ltnmp_phpmyadmin} /home/www/default/phpmyadmin

    cp ${current_dir}/lib/conf/config.inc.php /home/www/default/phpmyadmin/
    sed -i 's/LOVEANDY/LOVE'${RANDOM}'ANDY/g' /home/www/default/phpmyadmin/config.inc.php
    chmod -R 755 /home/www/default/phpmyadmin/
    chown -R www:www /home/www/default/phpmyadmin/

}