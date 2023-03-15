#!/bin/bash
echo "-----网卡SR-IOV配置脚本，GitHub：https://github.com/gngpp/profiles -----"

if [ -z "$(command -v lshw)" ]; then
    # 需要安装lshw具工
    sudo apt update && sudo apt install lshw -y
fi

SUPPORT_DEVICES="$(
    for i in $(find /sys/devices/* -name "sriov_numvfs" | cut -d "/" -f6); do echo $i $(lspci -vs $i | grep DeviceName | cut -d ":" -f 2); done
)"

if [ -z "$SUPPORT_DEVICES" ]; then
    echo "设备没有支持开启SR-IOV的网卡"
    exit 0
fi

echo -e "支持的设备有：\n$SUPPORT_DEVICES\n以上打印的都是设备bus ID"

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
                echo "$super_iface_name-$vf_id-$iface_name | $bus_device_id"-"$iface_name"-"$new_mac"

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
        systemctl enable $PROFILE --now
    fi
    # 显示对比
    ip link show $super_iface_name
}

echo "选择下面选项"
echo "[1] 设置vf数量"
echo "[2] 生成daemon服务"

read -p "选择：" choose
case $choose in
[1])
    handler "vf"
    ;;

[2])
    handler "daemon"
    ;;

*)
    exit 0
    ;;
esac
