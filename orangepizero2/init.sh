#!/bin/bash
 sed -i '$i ip link set eth0 promisc on'  /etc/rc.local
 sed -i '$i nohup /root/docker-profiles/orangepizero2/rc.sh &'  /etc/rc.local
