



#添加本地执行路径
#export LD_LIBRARY_PATH=./

#while true; do
        #启动一个循环，定时检查进程是否存在
        #for i in [zabbix_server,]
        #server=`ps aux | grep CenterServer_d | grep -v grep`
        #if [ ! "$server" ]; then
            #如果不存在就重新启动
        #    nohup ./CenterServer_d -c 1 &
            #启动后沉睡10s
        #    sleep 10
        #fi
        #每次循环沉睡10s
        #sleep 5
#done

##用于周期监测zabbix相关服务的运行，监测异常执行重启操作
#!/bin/bash
##The scripts Powerd By Chenlei
NOC_SERVICES_ALL={'mysqld','zabbix_server','zabbix_agentd','nginx','php-fpm'}
#启动一个循环，定时检查进程是否存在
while true; do
    
    for i in ('mysqld','zabbix_server','zabbix_agentd','nginx','php-fpm')
    SERVER_NAME=`netstat -anptu | grep $NOC_SERVICES_ALL`
    #判断服务进程是否存在
    [ ! "$SERVER_NAME" ]; then
        /etc/init.d/$SERVER_NAME START
        sleep 5
    fi
    #每次循环沉睡5s
    sleep 5
done