#!/bin/bash
sed -i '$i ip link set eth0 promisc on'  /etc/rc.local
sed -i '$i nohup $(pwd)/rc.sh &'  /etc/rc.local
echo "* * * * * nohup $(pwd)/ping.sh &" >> /etc/crontab