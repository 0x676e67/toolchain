#!/bin/bash
eth=eth
for i in {0..2}; do
    e1=$(ls /sys/class/net | grep $eth$i)
    if [ -n "$e1" ]; then
        echo "Found $eth$i, trying to activete now"
        e11=$(iconfig | grep $eth$i)
        if [ -n "$e11" ]; then
            echo "$eth$i has been activeted already"
        else
            ip link set $eth$i up
            e12=$(ifconfig | grep $eth$i)
            if [ -n "$e12" ]; then
                ip link set $eth$i down
                touch /etc/sysconfig/network-scripts/ifcfg-$eth$i
                echo "BOOTPROTO=dhcp" >>/etc/sysconfig/network-scripts/ifcfg-$eth$i
                echo "DEVICE=eth$i" >>/etc/sysconfig/network-scripts/ifcfg-$eth$i
                echo "ONBOOT=yes" >>/etc/sysconfig/network-scripts/ifcfg-$eth$i
                ip link set $eth$i up
                echo "  ** $eth$i activated **"

            else
                echo "  !! $eth$i activation failed !!"
            fi
        fi
    else
        echo "  !! $eth$i is unavailable !!"
    fi
done
