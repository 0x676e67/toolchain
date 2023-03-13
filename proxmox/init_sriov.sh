#!/bin/bash
echo "-----网卡SR-IOV配置脚本，GitHub：https://github.com/gngpp/profiles -----"

# 需要安装lshw工具
sudo apt update && sudo apt install lshw -y

SUPPORT_DEVICES="$(for i in ` find /sys/devices/* -name "sriov_numvfs"|cut -d "/" -f6`;do echo $i `lspci -vs $i |grep DeviceName|cut -d ":" -f 2` ;done
)"

if [ -z "$SUPPORT_DEVICES" ]; then
    echo "设备没有支持开启SR-IOV的网卡"
    exit 0
fi

echo -e "支持的设备有：\n$SUPPORT_DEVICES\n以上打印的都是设备bus ID"


echo "选择下面选项"
echo "[1] 设置vf数量"
echo "[2] 生成daemon服务"

read -p "选择：" choose
case $choose in
[1])    
    echo -n "输入设备bus ID："
    read choose_bus_id
    echo "该设备支持最大vf：$(cat /sys/bus/pci/devices/$choose_bus_id/sriov_totalvfs)"

    echo -n "输入需要开启vf数量:"
    read enable_device_vf_number
    echo $enable_device_vf_number > /sys/bus/pci/devices/$choose_bus_id/sriov_numvfs

    #echo "根据bus ID设置vf网卡mac地址"
    #pci_devices_ids=$(lspci | grep 'Virtual Function' | awk '{print $1}')
    #readarray -t pci_array <<< "$pci_devices_ids"
    #for bus_device_id in "${pci_array[@]}"
    #do
    #    hash_value=$(echo -n $bus_device_id | md5sum | awk '{print $1}')
    #    mac_address=$(printf "%02x:%02x:%02x:%02x:%02x:%02x\n" 0x${hash_value:0:2} 0x${hash_value:2:2} 0x${hash_value:4:2} 0x${hash_value:6:2} 0x${hash_value:8:2} 0x${hash_value:10:2})
    #    iface_name=$(lshw -businfo -c network | grep $bus_device_id | awk '{print $2}')
    #    echo "$bus_device_id"-"$iface_name"-"$mac_address"
    #    vf_id=$(echo "$iface_name" | sed -E 's/.*v(.*)/\1/')
    #    super_iface_name=${iface_name//v*/}
    #    ip link set $super_iface_name vf $vf_id mac "$mac_address"
    #done

    exit 0
;;

[2])
    echo -n "输入设备bus ID："
    read choose_bus_id
    echo "该设备支持最大vf：$(cat /sys/bus/pci/devices/$choose_bus_id/sriov_totalvfs)"

    echo -n "输入需要开启vf数量:"
    read enable_device_vf_number
    echo $enable_device_vf_number > /sys/bus/pci/devices/$choose_bus_id/sriov_numvfs

    PREFIX="sriov."
    SUFFIX=".service"
    PROFILE="$PREFIX$choose_bus_id$SUFFIX"

    #pci_devices_ids=$(lspci | grep 'Virtual Function' | awk '{print $1}')
    #readarray -t pci_array <<< "$pci_devices_ids"
    #for bus_device_id in "${pci_array[@]}"
    #do
    #    hash_value=$(echo -n $bus_device_id | md5sum | awk '{print $1}')
    #    mac_address=$(printf "%02x:%02x:%02x:%02x:%02x:%02x\n" 0x${hash_value:0:2} 0x${hash_value:2:2} 0x${hash_value:4:2} 0x${hash_value:6:2} 0x${hash_value:8:2} 0x${hash_value:10:2})
    #    iface_name=$(lshw -businfo -c network | grep $bus_device_id | awk '{print $2}')
    #    echo "$bus_device_id"-"$iface_name"-"$mac_address"
    #done

    DAEMON_CONFIG="[Unit]
    Description=Enable SR-IOV
    
    [Service]
    Type=sriov

    ExecStart=/usr/bin/bash -c '/usr/bin/echo $enable_device_vf_number > /sys/bus/pci/devices/$choose_bus_id/sriov_numvfs'

    [Install]
    WantedBy=multi-user.target
    "

    mkdir -p -v /etc/systemd/system
    echo -e "$DAEMON_CONFIG" > "/etc/systemd/system/$PROFILE"
    systemctl enable $PROFILE --now
;;

*)
exit 0
;;
esac