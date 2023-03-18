#!/bin/bash
echo "-----网卡SR-IOV配置脚本，GitHub：https://github.com/gngpp/profiles -----"
C_RED='\e[0;31m'
C_GREEN='\e[0;32m'
C_NC='\e[0m'

if [ -z "$(command -v lshw)" ]; then
    echo -e "${C_GREEN}开始安装lshw${C_NC}"
    sudo apt update && sudo apt install lshw -y
fi

SUPPORT_DEVICES="$(
    for i in $(find /sys/devices/* -name "sriov_numvfs" | cut -d "/" -f6); do echo $i $(lspci -vs $i | grep DeviceName | cut -d ":" -f 2); done
)"

if [ -z "$SUPPORT_DEVICES" ]; then
    echo -e "${C_RED}设备没有支持开启SR-IOV的网卡${C_NC}"
    exit 0
fi

echo -e "${C_GREEN}支持的设备有：\n$SUPPORT_DEVICES\n以上打印的都是设备Bus ID${C_NC}"

function handler() {
    echo -n "输入设备bus ID："
    read choose_bus_id
    echo "该设备支持最大vf：$(cat /sys/bus/pci/devices/$choose_bus_id/sriov_totalvfs)"

    echo -n "输入需要开启vf数量:"
    read enable_device_vf_number
    echo $enable_device_vf_number >/sys/bus/pci/devices/$choose_bus_id/sriov_numvfs

    super_iface_name="$(lshw -businfo -c network | grep $choose_bus_id | awk '{print $2}' | sed 's/ //g')"
    echo "根据pf mac地址生成设置vf网卡mac地址"
    commands_for_mac=""
    commands_for_trust=""
    commands_for_state=""
    commands_for_spoofchk=""
    pci_devices_ids=$(lspci | grep 'Virtual Function' | awk '{print $1}')
    readarray -t pci_array <<<"$pci_devices_ids"
    for bus_device_id in "${pci_array[@]}"; do
        iface_name="$(lshw -businfo -c network | grep $bus_device_id | awk '{print $2}' | sed 's/ //g')"
        if echo $iface_name | grep -q $super_iface_name; then
            if [ -n "$iface_name" ] && [ "$iface_name" != "network" ]; then
                vf_id="$(echo "$iface_name" | sed -E 's/.*v(.*)/\1/' | sed 's/ //g')"
                #super_iface_name="$(echo $iface_name | sed 's/v.*//' | sed 's/ //g')"
                super_iface_name_suffix="$(echo $super_iface_name | sed 's/.*\([0-9]\)$/\1/' | sed 's/ //g')"
                super_iface_mac="$(ip link show $super_iface_name | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' | head -n 1 | sed 's/ //g')"
                # 根据pf网卡mac地址递增计算vf网卡地址
                y=$(expr $(expr ${super_iface_name_suffix:-0} + $enable_device_vf_number + 1) \* $(expr ${vf_id:-0} + $enable_device_vf_number + 1) | bc)
                mac_num_16="0x$(echo "$super_iface_mac" | tr -d ':')"
                mac_num_10=$((num = $mac_num_16))
                mac_num_10=$(expr $y + $mac_num_10)
                new_mac=$(echo "obase=16;$mac_num_10" | bc)
                new_mac=$(echo $new_mac | sed -E 's/(..)(..)(..)(..)(..)(..)/\1:\2:\3:\4:\5:\6/g')
                echo -e "${C_GREEN}$super_iface_name-$vf_id-$iface_name | $bus_device_id"-"$iface_name"-"$new_mac${C_CN}"

                if [ "$1" == "vf" ]; then
                    ip link set dev $super_iface_name vf $vf_id trust on
                    ip link set dev $super_iface_name vf $vf_id mac $new_mac
                    ip link set dev $super_iface_name vf $vf_id state enable
                    ip link set dev $super_iface_name vf $vf_id spoofchk off
                fi

                if [ "$1" == "daemon" ]; then
                    command_for_trust="ExecStart=/usr/bin/bash -c '/usr/bin/ip link set dev $super_iface_name vf $vf_id trust on'"
                    command_for_state="ExecStart=/usr/bin/bash -c '/usr/bin/ip link set dev $super_iface_name vf $vf_id state enable'"
                    command_for_mac="ExecStart=/usr/bin/bash -c '/usr/bin/ip link set dev $super_iface_name vf $vf_id mac $new_mac'"
                    command_for_spoofchk="ExecStart=/usr/bin/bash -c '/usr/bin/ip link set dev $super_iface_name vf $vf_id spoofchk off'"

                    commands_for_trust="$commands_for_trust\n$command_for_trust"
                    commands_for_state="$commands_for_state\n$command_for_state"
                    commands_for_mac="$commands_for_mac\n$command_for_mac"
                    commands_for_spoofchk="$commands_for_spoofchk\n$command_for_spoofchk"
                fi
            fi
        fi
    done

    if [ "$1" == "daemon" ]; then
        echo -e "${C_GREEN}开始创建Daemon服务${C_NC}"
        PREFIX="sriov."
        SUFFIX=".service"
        PROFILE="$PREFIX$choose_bus_id$SUFFIX"
        DAEMON_CONFIG="[Unit]
Description=Enable SR-IOV
    
[Service]
Type=oneshot

ExecStart=/usr/bin/bash -c '/usr/bin/echo $enable_device_vf_number > /sys/bus/pci/devices/$choose_bus_id/sriov_numvfs'

$(echo -e $commands_for_trust)
$(echo -e $commands_for_state)
$(echo -e $commands_for_spoofchk)
$(echo -e $commands_for_mac)

[Install]
WantedBy=multi-user.target
"
        mkdir -p -v /etc/systemd/system
        echo -e "$DAEMON_CONFIG" >"/etc/systemd/system/$PROFILE"
        echo -e "${C_GREEN}创建Daemon服务完毕${C_NC}"
        systemctl daemon-reload
        systemctl enable $PROFILE --now
        echo -e "${C_GREEN}Daemon服务已启动${C_NC}"
    fi
    # 显示对比
    ip link show $super_iface_name
}

echo "[1] 创建VF并启用"
echo "[2] 创建VF开机Daemon服务"
echo "[3] 创建定时任务ForwardDB检查"

read -p "选择：" choose
case $choose in
[1])
    handler "vf"
    ;;

[2])
    handler "daemon"
    ;;
[3])
    echo -e "${C_GREEN}脚本将创建定时检查容器或 VM 的所有 mac 地址是否已经在接口的 ForwardDB 中，若不在则加入ForwardDB${C_NC}"
    echo -n "输入设备Bus ID："
    read choose_bus_id
    super_iface_name="$(lshw -businfo -c network | grep $choose_bus_id | awk '{print $2}' | sed 's/ //g')"
    echo -e "${C_GREEN}容器配置默认路径：/etc/pve/nodes/proxmox/lxc${C_NC}"
    echo -e "${C_GREEN}VM配置默认路径：/etc/pve/nodes/proxmox/qemu-server${C_NC}"

    echo -n "输入绑定PF的网桥："
    read pf_vm
    echo -n "输入定时检查分钟："
    read check_min
    check_min="$check_min"min

    echo -e "${C_GREEN}开始下载脚本${C_NC}"
    wget https://ghproxy.com/https://raw.githubusercontent.com/gngpp/profiles/master/proxmox/sr-iov-registermacaddr.sh -O /etc/sr-iov-registermacaddr.sh
    chmod +x /etc/sr-iov-registermacaddr.sh

    echo -e "${C_GREEN}开始创建Daemon服务${C_NC}"
    TIMER_PROFILE="sriov-$pf_vm-$super_iface_name.timer"
    PROFILE="sriov-$pf_vm-$super_iface_name.service"
    TIMER_DAEMON_CONFIG="[Unit]
Description=Enable SR-IOV ForwardDB Check Timer
Requires=$PROFILE

[Timer]
Unit=$PROFILE
OnUnitActiveSec=$check_min

[Install]
WantedBy=timers.target
"
    DAEMON_CONFIG="[Unit]
Description=SR-IOV ForwardDB Check
Wants=$TIMER_PROFILE

[Service]
Type=simple
ExecStart=/usr/bin/bash -c '/etc/sr-iov-registermacaddr.sh $super_iface_name $pf_vm'

[Install]
WantedBy=multi-user.target
"
        mkdir -p -v /etc/systemd/system
        echo -e "$DAEMON_CONFIG" >"/etc/systemd/system/$PROFILE"
        echo -e "$TIMER_DAEMON_CONFIG" >"/etc/systemd/system/$TIMER_PROFILE"
        echo -e "${C_GREEN}创建daemon服务完毕${C_NC}"
        systemctl daemon-reload
        systemctl enable $PROFILE --now
        systemctl enable $TIMER_PROFILE --now
        echo -e "${C_GREEN}daemon服务已启动${C_NC}"
;;
*)
    exit 0
    ;;
esac
