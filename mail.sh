#!/bin/sh
echo "$3"> /usr/local/zabbix/share/zabbix/alertscripts/youjian.txt
dos2unix -k /usr/local/zabbix/share/zabbix/alertscripts/youjian.txt
mail -s "$2" $1 </usr/local/zabbix/share/zabbix/alertscripts/youjian.txt
