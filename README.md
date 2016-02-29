#ltnmp一键安装包

![ltnmp logo](http://static.oschina.net/uploads/space/2016/0120/115109_yi4W_1412792.gif)

ltnmp一键安装包是一个用Linux Shell编写的可以为CentOS/RadHat、Debian/Ubuntu VPS(VDS)或独立主机安装ltnmp(Linux、Tengine/Nginx、PHP、MariaDB/Mysql、phpMyAdmin)生产环境的Shell程序。ltnmp一键安装包是基于主要增加了淘宝服务器Tengine和MariaDB。

最新版本各个组件已经独立开来，可以单独的安装。

安装过程可选组件：nginx，mysql

安装完成后可选安装组件：redis，phalcon，yaf，swoole，composer，ioncube Loader，Zend Guard Loader


#Git
> [https://git.oschina.net/php360/ltnmp](https://git.oschina.net/php360/ltnmp)
>
> [https://github.com/php360/ltnmp](https://github.com/php360/ltnmp)

#安装使用教程
链接：[http://www.moqifei.com/ltnmp](http://www.moqifei.com/ltnmp)

ltnmp一键安装包By：技安(Andy) php360#qq.com(把#换成@)

#注意
> 内存低于1G的服务器在没有swap交换分区
>
> 安装数据库的时候会因为内存不足而安装失败
>
> 需要增加swap交换分区才可以正常安装
>
> 增加swap的方法详见：[http://www.moqifei.com/archives/1916](http://www.moqifei.com/archives/1916)

#更新记录
###3.1更新组件：
* 更新redis不支持php7的非官方版

###3.0更新组件：
* tengine-2.1.2
* nginx-1.9.9
* php-7.0.2
* phpMyAdmin-4.5.3.1-all-languages
* mariadb-10.1.10
* mysql-5.7.10
* 调整php-fpm的sock位置至/dev/shm/php-cgi.sock,使之更快的运行

---
* 开发分支增加：
* openlitespeed
* memcached
* CentOS 6 系统初始优化脚本：Optimization_centos6_x86_64.sh(由Ricky提供)

---
    2.1.1：
    更新swoole为最新稳定版1.7.19
    2.1.0：
    该版本默认安装：tengine-2.1.1，php-5.6.12，mariadb-10.0.21，phpMyAdmin-4.4.14-all-languages
    安装过程可选组件：nginx-1.9.4，mysql-5.6.26
    安装完成后可选安装组件：redis-3.0.3，phalcon-v2.0.7，yaf-2.3.3，
    swoole-1.7.18-stable，composer-1.0-dev，ioncube Loader，Zend Guard Loader
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
