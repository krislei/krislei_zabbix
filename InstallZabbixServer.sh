#!/bin/bash
###################################################################################
#############                                                         #############
#############                 Power by Chenlei                        #############
#############                                                         #############
#############                        LastCreatedBy 20170730           #############
#############                                                         #############
#############                                                         #############
####################################################################################
CUR_PATH=$(cd `dirname $0`; pwd)
ZABBIX_PATH=${CUR_PATH}/zabbix-2.4.6
NGINX_PATH=${CUR_PATH}/nginx-1.10.2
ZABBIX_TAR=${CUR_PATH}/zabbix.tar.gz
NGINX_TAR=${CUR_PATH}/nginx-1.10.2.tar.gz
DBUSER=zabbix
DBPASSWD=zabbix
WEB_PATH=/usr/local/nginx/html
ZABBIX_INSTALL_PATH=/usr/local/zabbix
VERSION=$(cat /etc/redhat-release |awk '{print $1}')


#安装软件包
if [ ${VERSION} = "CentOS" ];then
    yum -y install mailx mysql-dev mysql-server gcc net-snmp-devel curl-devel perl-DBI php-gd php-mysql php-bcmath php-mbstring  php-fpm   mysql-devel php-xml pcre-devel
else
    cp -rf ${CUR_PATH}/CentOS-Base.repo /etc/yum.repos.d/
    yum clean all
    yum makecache
    yum -y install mailx mysql-dev mysql-server gcc net-snmp-devel curl-devel perl-DBI php-gd php-mysql php-bcmath php-mbstring  php-fpm   mysql-devel php-xml pcre-devel
fi

#添加zabbix用户组
groupadd zabbix
useradd -g zabbix -s /sbin/nologin -M zabbix


# 解压安装包
rm -rf ${ZABBIX_PATH} 
rm -rf ${NGINX_PATH} 
tar -zvxf ${ZABBIX_TAR}
tar -zvxf ${NGINX_TAR}

# 准备DB
/etc/init.d/mysqld start
mysql -uroot -e "grant all privileges on zabbix.* to ${DBUSER}@'localhost' identified by \"${DBPASSWD}\""
mysql -uroot -e "flush privileges"
mysql -u${DBUSER} -p${DBPASSWD} -e 'create database zabbix character set utf8'
cd ${ZABBIX_PATH}/database/mysql 
mysql -u${DBUSER} -p${DBPASSWD} zabbix < schema.sql
mysql -u${DBUSER} -p${DBPASSWD} zabbix < images.sql
mysql -u${DBUSER} -p${DBPASSWD} zabbix < data.sql

# 编译安装zabbix
cd ${ZABBIX_PATH}
./configure --prefix=/usr/local/zabbix --with-mysql --with-net-snmp --with-libcurl --enable-server --enable-agent --enable-proxy 
make && make install

# 编译安装nginx
cd ${NGINX_PATH}
./configure --prefix=/usr/local/nginx
make && make install

# 更换nginx的配置文件
cp -rf ${CUR_PATH}/nginx.conf /usr/local/nginx/conf/

# 添加web php文件
cp -rf ${ZABBIX_PATH}/frontends/php ${WEB_PATH}/zabbix
chown -R zabbix:zabbix ${WEB_PATH}/zabbix

# 添加邮件发送文件
cp -rf ${CUR_PATH}/mail.sh /usr/local/zabbix/share/zabbix/alertscripts/
touch  /usr/local/zabbix/share/zabbix/alertscripts/youjian.txt
chmod 777 /usr/local/zabbix/share/zabbix/alertscripts/mail.sh
chmod 777 /usr/local/zabbix/share/zabbix/alertscripts/youjian.txt

# 修改zabbix页面配置文件
cp -rf ${CUR_PATH}/zabbix.conf.php /usr/local/nginx/html/zabbix/conf/


#设置开机启动
#echo '/usr/local/zabbix/sbin/zabbix_server start' >> /etc/rc.d/rc.local
#echo '/usr/local/zabbix/sbin/zabbix_agentd start' >> /etc/rc.d/rc.local
#cho '/etc/init.d/nginx start' >> /etc/rc.d/rc.local
#echo '/etc/init.d/mysqld start' >> /etc/rc.d/rc.local
#echo '/etc/init.d/php-fpm start' >> /etc/rc.d/rc.local

# 修改php配置文件
cp -rf ${CUR_PATH}/php.ini /etc/

# 添加启动项
cp -rf ${CUR_PATH}/zabbix_agentd /etc/init.d/
cp -rf ${CUR_PATH}/zabbix_server /etc/init.d/
cp -rf ${CUR_PATH}/nginx /etc/init.d/
chmod a+x /etc/init.d/zabbix* 
#chmod 777 /etc/init.d/zabbix_server
chmod a+x /etc/init.d/nginx

#增加所需的服务
chkconfig --level 35 mysqld on 
chkconfig --level 35 php-fpm on 
chkconfig --level 35 nginx on 
chkconfig --level 35 zabbix_agentd on 
chkconfig --level 35 zabbix_server on 

#增加防火墙策略
#/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3000-j ACCEPT
/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8888 -j ACCEPT
/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT
/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 10051 -j ACCEPT
/etc/init.d/iptables save && /etc/init.d/iptables restart

#设置报警发件人
cat ${CUR_PATH}/setmail_info.sh >> /etc/mail.rc
# 重启进程
service mysqld restart 
service php-fpm restart
/etc/init.d/zabbix_server restart 
/etc/init.d/zabbix_agentd restart 
/etc/init.d/nginx restart

#安装grafana软件
#rpm -ivh ${CUR_PATH}/grafana-3.1.1-1470047149.x86_64.rpm
#安装grafana_zabbix插件
#cp -rf ${CUR_PATH}/grafana-zabbix/zabbix/  /usr/share/grafana/public/app/plugins/datasource/
#启动grafana服务
#grafana-cli plugins install alexanderzobnin-zabbix-app  &&  service grafana-server start
#chkconfig grafana-server on
#检查服务状态并输出
#echo "Install finished , Check the status of service in "1-mysql,2-nginx,3-zabbix,4-grafana,5-php"
#netstat -anptu | grep -e mysql -e php -e zabbix -e grafana -e nginx 
netstat -anptu | grep -e mysql -e php -e zabbix  -e nginx 






