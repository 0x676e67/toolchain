#!/usr/bin/bash
#
# vf_add_maddr.sh Version 1.1
# Script is based on kriss35
# Update by Rama: Added vmbridge macaddress itself, simplified, systemd-service(RestartOnFailure) Compatible and speeded up with a tmpfile(one readout).
# Usage: execute directly without arguments, make an systemd-service or add it to crontab to run every x Minutes.
#
CTCONFDIR=/etc/pve/nodes/proxmox/lxc
VMCONFDIR=/etc/pve/nodes/proxmox/qemu-server
IFBRIDGE=$1
LBRIDGE=$2
TMP_FILE=/tmp/vf_add_maddr.tmp

C_RED='\e[0;31m'
C_GREEN='\e[0;32m'
C_NC='\e[0m'

if [ ! -d $CTCONFDIR ] || [ ! -d $VMCONFDIR ]; then
        echo -e "${C_RED}ERROR: Not mounted, self restart in 5s!${C_NC}"
        exit 1
else
        MAC_LIST_VMS=" $(cat ${VMCONFDIR}/*.conf | grep bridge | grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | tr '[:upper:]' '[:lower:]') $(cat ${CTCONFDIR}/*.conf | grep hwaddr | grep -Eo '([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}' | tr '[:upper:]' '[:lower:]')"
        MAC_ADD2LIST="$(cat /sys/class/net/$LBRIDGE/address)"
        MAC_LIST="$MAC_LIST_VMS $MAC_ADD2LIST"
        /usr/sbin/bridge fdb show | grep "${IFBRIDGE} self permanent" > $TMP_FILE

        for mactoregister in ${MAC_LIST}; do
                if ( grep -Fq $mactoregister $TMP_FILE ); then
                        echo -e "${C_GREEN}$mactoregister${C_NC} - Exists $IFBRIDGE-$LBRIDGE!"
                        logger -p user.info -t "registermacaddr" "${C_GREEN}$mactoregister${C_NC} - Exists $IFBRIDGE-$LBRIDGE!"
                else
                        /usr/sbin/bridge fdb add $mactoregister dev ${IFBRIDGE}
                        echo -e "${C_RED}$mactoregister${C_NC} - Added $IFBRIDGE-$LBRIDGE!"
                        logger -p user.info -t "registermacaddr" "${C_RED}$mactoregister${C_NC} - Added $IFBRIDGE-$LBRIDGE!"
                fi
        done
        exit 0
fi