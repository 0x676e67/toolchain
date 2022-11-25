#!/bin/bash

#

for i in {0..20};do


     if ping -c 1 -w 1 192.168.4.1 &> /dev/null;then

        break;

     else

        command="$(docker restart openwrt_master)"
	echo $command

     fi


done
