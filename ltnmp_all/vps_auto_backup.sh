#! /bin/bash
#====================================================================
# vps_auto_backup.sh
#
# Copyright (c) 2013, php360 <php360@qq.com>
# All rights reserved.
# Distributed under the GNU General Public License, version 3.0.
#
# vps automatic local and offsite backup shell cript
#
# See: http://www.05gzs.com/
#
#====================================================================

BACKUP_DIR="/root/vps-bak"            # Backup data storage directory

ENABLE_MYSQL_BACKUP="1"               # Disable=0 Enable=1
MYSQL_BACKUP_CYCLE="86400"            # 1hour=3600second,24hour=86400second
MYSQL_BACKUP_NUM="3"                  # Number of backup data
MYSQL_HOST="localhost"                # MySQL host ip address
MYSQL_USER="root"                     # MySQL user name
MYSQL_PWD="123456"                    # MySQL user password
MYSQL_DB_NAMES="all"                  # db1 db2 db3 or all
MYSQL_EXCLUDE_DB="phpmyadmin|information_schema|performance_schema"

ENABLE_LOCAL_BACKUP="1"               # Disable=0, Enable=1
WWW_BACKUP_CYCLE="86400"              # 1hour=3600second,24hour=86400second
WWW_BACKUP_NUM="3"                    # Number of backup data
WWW_BACKUP_DIRS="/home /chroot/home"  # Directory you want to backup data
WWW_BACKUP_DEPTH="1"                  # Folder=0, Folder+subfolder =1

ENABLE_FTP_BACKUP="0"                 # Disable=0, Enable=1
FTP_BACKUP_CYCLE="604800"             # Always=0,1hour=3600second,7day=604800second
FTP_BACKUP_MODE="0"                   # Full backup=0, Incremental backup=1
FTP_REMOTE_DIR="vps-bak"              # Remote backup data storage directory
FTP_HOSTNAME="192.168.8.128"          # Remote ftp host ip address
FTP_USERNAME="test"                   # Remote ftp user name
FTP_PASSWORD="test"                   # Remote ftp user password

ENABLE_SCP_BACKUP="0"                 # Disable=0, Enable=1
SCP_BACKUP_CYCLE="604800"             # Always=0,1hour=3600second,7day=604800second
SCP_HOST="192.168.8.128"              # Remote host ip address
SCP_USER="root"                       # Remote host user name
SCP_PASSWD="123456"                   # Remote host user password
SCP_REMOTE_PATH="/root/vps-bak"       # Remote backup data storage directory

ENABLE_S3_BACKUP="0"                  # Disable=0, Enable=1
S3_BACKUP_CYCLE="604800"              # Always=0,1hour=3600second,7day=604800second
S3_BACKUP_MODE="0"                    # Full backup=0, Incremental backup=1
S3_BUCKET="vps-bak"                   # Amazon s3 bucket
ACCESS_KEY_ID="123456"                # Amazon access key
SECRET_ACCESS_KEY="123456"            # Amazon secret access key

#====================================================================

if [ ! -d "$BACKUP_DIR" ];then
	mkdir -p $BACKUP_DIR/{mysql,logs,www}
	chmod -R 711 $BACKUP_DIR
fi

for logName in mysql www ftp scp s3
do
	if [ ! -s "$BACKUP_DIR/logs/${logName}.log" ];then
		echo -e "0\t0" > $BACKUP_DIR/logs/${logName}.log
	fi
done

unixTime=$(date +%s)
dateTime=$(date +%Y%m%d%H%M%S)

#====================================================================

if [ "$ENABLE_MYSQL_BACKUP" = 1 ];then
	mysqlBakPre=$(awk NR==1'{print $1}' $BACKUP_DIR/logs/mysql.log)
	mysqlBakSwitch=$(($unixTime-$mysqlBakPre>$MYSQL_BACKUP_CYCLE))
	if [ "$mysqlBakSwitch" = 1 ]; then
		echo -e "${unixTime}\t${dateTime}" >> $BACKUP_DIR/logs/mysql.log
		if [[ "$MYSQL_DB_NAMES" = "ALL" || "$MYSQL_DB_NAMES" = "All" || "$MYSQL_DB_NAMES" = "all" ]]; then
			MYSQL_DB_NAMES="$(mysql -u $MYSQL_USER -p$MYSQL_PWD -Bse 'show databases')"
		fi
		for MYSQL_DB_NAME in $MYSQL_DB_NAMES
		do
			MYSQL_DB_NAME=`echo $MYSQL_DB_NAME | grep -Ev $MYSQL_EXCLUDE_DB`
			if [ -z "$MYSQL_DB_NAME" ];then
				continue
			fi
			mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PWD \
			$MYSQL_DB_NAME | gzip -9 > $BACKUP_DIR/mysql/$MYSQL_DB_NAME-$dateTime.sql.gz
		done
		echo "$(date +%Y-%m-%d\ %T) - MySQL backup successful" | tee -a $BACKUP_DIR/logs/log.txt
	fi
	[ "$mysqlBakPre" = 0 ] && sed -i '1d' $BACKUP_DIR/logs/mysql.log
	dbRmNum=$(($(awk 'END{print NR}' $BACKUP_DIR/logs/mysql.log)-$MYSQL_BACKUP_NUM))
	for (( i=0; i < $dbRmNum; i++ )); do
		dbRmTime=$(awk 'NR==1{print $2}' $BACKUP_DIR/logs/mysql.log)
		sed -i '1d' $BACKUP_DIR/logs/mysql.log
		rm -rf $BACKUP_DIR/mysql/*-$dbRmTime.sql.gz
	done
	if [ `echo "$dbRmNum > 0" | bc` -eq 1 ];then
		echo "$(date +%Y-%m-%d\ %T) - MySQL database delete successful [$dbRmNum Records]" | tee -a $BACKUP_DIR/logs/log.txt
	fi
fi

#====================================================================

if [ "$ENABLE_LOCAL_BACKUP" = 1 ];then
	wwwBakPre=$(awk NR==1'{print $1}' $BACKUP_DIR/logs/www.log)
	wwwBakSwitch=$(($unixTime-$wwwBakPre>$WWW_BACKUP_CYCLE))
	if [ "$wwwBakSwitch" = 1 ]; then
		echo -e "${unixTime}\t${dateTime}" >> $BACKUP_DIR/logs/www.log
		for WWW_BACKUP_DIR in $WWW_BACKUP_DIRS;do
			cd $WWW_BACKUP_DIR
			dirName=`echo $WWW_BACKUP_DIR | awk -F/ '{print $NF}'`
			if [ "$WWW_BACKUP_DEPTH" = 1 ];then
				dirs=`ls`
				for dir in $dirs;do
					tar -zcf $BACKUP_DIR/www/${dirName}-$dir-$dateTime.tar.gz $dir
				done
			else
				cd ../
				tar -zcf $BACKUP_DIR/www/$dirName-$dateTime.tar.gz $dirName
			fi
		done
		echo "$(date +%Y-%m-%d\ %T) - www date backup successful" | tee -a $BACKUP_DIR/logs/log.txt
		[ "$wwwBakPre" = 0 ] && sed -i '1d' $BACKUP_DIR/logs/www.log
		wwwRmNum=$(($(awk 'END{print NR}' $BACKUP_DIR/logs/www.log)-$WWW_BACKUP_NUM))
		for (( i=0; i < $wwwRmNum; i++ )); do
			wwwRmTime=$(awk 'NR==1{print $2}' $BACKUP_DIR/logs/www.log)
			sed -i '1d' $BACKUP_DIR/logs/www.log
			rm -rf $BACKUP_DIR/www/*-$wwwRmTime.tar.gz
		done
		if [ `echo "$wwwRmNum > 0" | bc` -eq 1 ];then
			echo "$(date +%Y-%m-%d\ %T) - www date delete successful [$wwwRmNum Records]" | tee -a $BACKUP_DIR/logs/log.txt
		fi
	fi
fi

#====================================================================

ftpBakSwitch=$(($unixTime-$(awk NR==1'{print $1}' $BACKUP_DIR/logs/ftp.log)>$FTP_BACKUP_CYCLE))

if [ "$ENABLE_FTP_BACKUP" = 1 -a "$ftpBakSwitch" = 1 ];then
	echo -e "${unixTime}\t${dateTime}" > $BACKUP_DIR/logs/ftp.log
	if [ "$mysqlBakSwitch" = 1 ];then
		lftp $FTP_HOSTNAME -u $FTP_USERNAME,$FTP_PASSWORD<<-EOF
		mkdir -p $FTP_REMOTE_DIR/mysql
		mirror -e -n -R --log=$BACKUP_DIR/logs/ftp.txt $BACKUP_DIR/mysql $FTP_REMOTE_DIR/mysql
		bye
		EOF
	fi
	if [ "$wwwBakSwitch" = 1 -a "$FTP_BACKUP_MODE" != 1 ];then
		lftp $FTP_HOSTNAME -u $FTP_USERNAME,$FTP_PASSWORD<<-EOF
		mkdir -p $FTP_REMOTE_DIR/www
		mirror -e -n -R --log=$BACKUP_DIR/logs/ftp.txt $BACKUP_DIR/www $FTP_REMOTE_DIR/www
		bye
		EOF
	fi
	if [ "$FTP_BACKUP_MODE" = 1 ];then
		for WWW_BACKUP_DIR in $WWW_BACKUP_DIRS;do
			lftp $FTP_HOSTNAME -u $FTP_USERNAME,$FTP_PASSWORD<<-EOF
			mkdir -p $FTP_REMOTE_DIR/home
			mirror -e -n -R --log=$BACKUP_DIR/logs/ftp.log $WWW_BACKUP_DIR $FTP_REMOTE_DIR/home
			bye
			EOF
		done
	fi
fi

#====================================================================

scpBakSwitch=$(($unixTime-$(awk NR==1'{print $1}' $BACKUP_DIR/logs/scp.log)>$SCP_BACKUP_CYCLE))

if [ "$ENABLE_SCP_BACKUP" = 1 -a "$scpBakSwitch" = 1 ];then
	echo -e "${unixTime}\t${dateTime}" > $BACKUP_DIR/logs/scp.log
	
	expect -c "
	spawn ssh ${SCP_USER}@${SCP_HOST}
	expect {
		\"yes/no\"
		{
			send \"yes\r\"
			expect \"password\" {send \"$SCP_PASSWD\r\"}
			expect \"]\" {send \"rm -rf $SCP_REMOTE_PATH;mkdir -p $SCP_REMOTE_PATH;exit\r\"}
		}
		\"password\"
		{
			send \"$SCP_PASSWD\r\"
			expect \"]\" {send \"rm -rf $SCP_REMOTE_PATH;mkdir -p $SCP_REMOTE_PATH;exit\r\"}
		}
	};interact" | tee -a $BACKUP_DIR/logs/scp.txt

	if [ "$mysqlBakSwitch" = 1 ];then
		expect -c "
		spawn scp -r $BACKUP_DIR/mysql/ ${SCP_USER}@${SCP_HOST}:${SCP_REMOTE_PATH}
		expect {
			\"yes/no\"
			{
				send \"yes\r\"
				expect \"password\" {send \"$SCP_PASSWD\r\"}
			}
			\"password\"
			{
				send \"$SCP_PASSWD\r\"
			}
		};interact" | tee -a $BACKUP_DIR/logs/scp.txt
	fi
	if [ "$wwwBakSwitch" = 1 ];then
		expect -c "
		spawn scp -r $BACKUP_DIR/www/ ${SCP_USER}@${SCP_HOST}:${SCP_REMOTE_PATH}
		expect {
			\"yes/no\"
			{
				send \"yes\r\"
				expect \"password\" {send \"$SCP_PASSWD\r\"}
			}
			\"password\"
			{
				send \"$SCP_PASSWD\r\"
			}
		};interact" | tee -a $BACKUP_DIR/logs/scp.txt
	fi
fi

#====================================================================

s3BakSwitch=$(($unixTime-$(awk NR==1'{print $1}' $BACKUP_DIR/logs/s3.log)>$S3_BACKUP_CYCLE))

if [ "$ENABLE_S3_BACKUP" = 1 ];then
	if [ ! -s "/root/.s3cfg" ];then
		wget http://wangyan.org/download/conf/.s3cfg -P ~/
		sed -i 's#ACCESS_KEY_ID#'$ACCESS_KEY_ID'#g' ~/.s3cfg
		sed -i 's#SECRET_ACCESS_KEY#'$SECRET_ACCESS_KEY'#g' ~/.s3cfg
		wget http://wangyan.org/download/src/s3cmd-1.0.1.tar.gz
		tar -zxf s3cmd-1.0.1.tar.gz -C /usr/local/
		mv /usr/local/s3cmd-1.0.1/ /usr/local/s3cmd/
		ln -s /usr/local/s3cmd/s3cmd /usr/bin/s3cmd
	fi
	if [ -z "`s3cmd ls | grep $S3_BUCKET`" ];then
		s3cmd mb s3://$S3_BUCKET
	fi
	if [ -n "`s3cmd ls | grep $S3_BUCKET`" -a "$s3BakSwitch" = 1 ];then
		echo -e "${unixTime}\t${dateTime}" > $BACKUP_DIR/logs/s3.log
		if [ "$mysqlBakSwitch" = 1 ];then
			s3cmd sync --delete-removed $BACKUP_DIR/mysql/ s3://$S3_BUCKET/mysql/ | tee -a $BACKUP_DIR/logs/s3.txt
		fi
		if [ "$wwwBakSwitch" = 1 -a "$S3_BACKUP_MODE" != 1 ];then
			if [ "$S3_BACKUP_MODE" != 1 ];then
				s3cmd sync --delete-removed $BACKUP_DIR/www/ s3://$S3_BUCKET/www/ | tee -a $BACKUP_DIR/logs/s3.txt
			fi
		fi
		if [ "$S3_BACKUP_MODE" = 1 ];then
			for WWW_BACKUP_DIR in $WWW_BACKUP_DIRS;do
				dirName=`echo $WWW_BACKUP_DIR | awk -F/ '{print $NF}'`
				s3cmd sync --delete-removed $WWW_BACKUP_DIR/ s3://$S3_BUCKET/$dirName/ | tee -a $BACKUP_DIR/logs/s3.txt
			done
		fi
	fi
fi
