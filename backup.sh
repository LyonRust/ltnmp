#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi

clear
echo "========================================================================="
echo "Backup script for LTNMP  Written by php360"
echo "========================================================================="
echo "LTNMP is a to auto-compile & install Tengine+Nginx+MySQL+PHP on Linux "
echo "This script is a tool to backup "
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="

mkdir /home/www/backup

#website file
echo "Which site would you backup?"
domain_list=$(cd /home/www && ls )
echo $domain_list | sed "s/ \{1,\}/\n/g"
printf "Please input the full domain:"
read domain

#mysql
printf "Do you want to backup mysql database?[y/n]"
read mysql_i
if [ $mysql_i = "y" ]; then
printf "Please input the root mysql password:"
read pd
echo ""
printf "Which database would you backup?"
echo ""
mysql -uroot -p$pd -B -N -e 'SHOW DATABASES' | xargs | sed "s/ \{1,\}/\n/g"
printf "Please input the whole name of the database:"
read db
db_f=${db}_$(date +"%Y%m%d").sql
mysqldump --user=root -p$pd $db > /home/www/backup/$db_f
fi


echo ""
cd /home/www
b_file=${domain}_$(date +"%Y%m%d").tar.gz
tar czvf $b_file $domain
mv $b_file /home/www/backup


echo "========================================================================="
echo "Done."
echo "The backup file is stored as /home/www/backup/"
echo "For more information please visit http://www.05gzs.com/"
echo ""
echo "========================================================================="

