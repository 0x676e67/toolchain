#!/bin/bash
for a in {1..30}
do
	if [[ -n $(docker ps -q -f name="openwrt_master") ]];then
		echo "nameserver 223.5.5.5" > /etc/resolv.conf
		route add default gw 192.168.4.1 br-$(docker network ls | grep orangepizero2_lan | awk -F ' ' '{print $1}')
		break;
	fi
        sleep 1
done

