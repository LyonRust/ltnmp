#ltnmp一键安装包

ltnmp一键安装包是一个用Linux Shell编写的可以为CentOS/RadHat、Debian/Ubuntu VPS(VDS)或独立主机安装ltnmp(Linux、Tengine/Nginx、PHP、MariaDB/Mysql、phpMyAdmin)生产环境的Shell程序。ltnmp一键安装包是基于lnmp基础上二次开发的一键安装包，增加了淘宝服务器Tengine和MariaDB。

默认安装组件：tengine，php，mariadb，phpMyAdmin

安装过程可选组件：nginx，mysql

安装完成后可选安装组件：redis，phalcon，yaf，swoole，composer，ioncube Loader，Zend Guard Loader


#Git
http://git.oschina.net/php360/ltnmp

https://github.com/php360/ltnmp

#安装使用教程
http://www.moqifei.com/ltnmp

ltnmp一键安装包By：技安(Andy) php360#qq.com(把#换成@)

#更新记录
2.1.0：
该版本默认安装：tengine-2.1.1，php-5.6.12，mariadb-10.0.21，phpMyAdmin-4.4.14-all-languages

安装过程可选组件：nginx-1.9.4，mysql-5.6.26

安装完成后可选安装组件：redis-3.0.3，phalcon-v2.0.7，yaf-2.3.3，swoole-1.7.18-stable，composer-1.0-dev，ioncube Loader，Zend Guard Loader

2.0.4：
更新composer到最新版，添加完成后添加可执行权限

增加数据库innodb存储引擎默认采用独立表存储数据

去掉添加虚拟主机时自动建立.user.ini目录限制文件，可以手动建立该文件。

添加nginx1.9.4和php5.6.12

增加更新php到5.6.12的升级脚本

增加了升级脚本(该版本提供php的升级，后续增加各个组件升级)

2.0.3：
增加composer安装脚本

2.0.2：
该版本是一个bug修复版本；修复添加虚拟主机无法运行php的bug

2.0.1：
ltnmp2.0发布。

1.0：
ltnmp1.0。
