#!/bin/sh
 TOP_SYS_LOAD_NUM=设定负载值
SYS_LOAD_NUM=`uptime | awk '{print $(NF-2)}' | sed 's/,//'`

 echo $(date +"%y-%m-%d") `uptime`
 if [ `echo "$TOP_SYS_LOAD_NUM < $SYS_LOAD_NUM"|bc` -eq 1 ]  
 then  
     echo "#0#" $(date +"%y-%m-%d %H:%M:%S") "pkill httpd" `ps -ef | grep httpd | wc -l`
     service httpd stop
     pkill httpd
     pkill php-cgi
     sleep 10  
     for i in 1 2 3  
     do  
         if [ `pgrep httpd | wc -l` -le 0 ]  
         then  
             service httpd start
             sleep 15  
             echo "#1#" $(date +"%y-%m-%d %H:%M:%S") "start httpd" `ps -ef | grep httpd | wc -l`  
         fi  
     done  
 else  
     if [ `pgrep httpd | wc -l` -le 0 ]  
     then  
         service httpd start  
         sleep 15  
         echo "#2#" $(date +"%y-%m-%d %H:%M:%S") "start httpd" `ps -ef | grep httpd | wc -l`  
     fi
 fi