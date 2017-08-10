#!/bin/bash
###################################################################################
#############                                                         #############
#############                 Power by Chenlei                        #############
#############                                                         #############
#############                        LastCreatedBy 20170803           #############
#############                                                         #############
#############                                                         #############
###################################################################################
read -p "请输入Zabbix Server的IP："  ZABBIX_SERVERIP
echo “即将安装zabbix，请稍后......”
CUR_PATH=$(cd `dirname $0`; pwd)
ZABBIX_PATH=${CUR_PATH}/zabbix-2.4.6
ZABBIX_TAR=${CUR_PATH}/zabbix.tar.gz
ZABBIX_INSTALL_PATH=/usr/local/zabbix
#添加zabbix用户组
groupadd zabbix
useradd -g zabbix -u zabbix -s /sbin/nologin -M zabbix
# 解压安装包
rm -rf ${ZABBIX_PATH} 
tar -zvxf ${ZABBIX_TAR}
# 编译安装zabbix
cd ${ZABBIX_PATH}
./configure --prefix=/usr/local/zabbix --enable-agent 
make && make install
# 添加启动项
cp -rf ${CUR_PATH}/zabbix_agentd /etc/init.d/ && chmod a+x /etc/init.d/zabbix* 
#增加所需的服务
chkconfig --level 35 zabbix_agentd on 
#修改监听的Server代理IP地址
sed -i 's/127.0.0.1/$ZABBIX_SERVERIP/g' /usr/local/zabbix/etc/zabbix_agentd.conf
#增加防火墙策略
/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT
/etc/init.d/iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 10051 -j ACCEPT
/etc/init.d/iptables save && /etc/init.d/iptables restart
# 重启进程
/etc/init.d/zabbix_agentd restart && netstat -anptu | grep zabbix——agentd





