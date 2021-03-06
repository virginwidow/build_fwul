#!/bin/bash
###########################################################################################
#
# session starter for FWUL
#
###########################################################################################

######
# Language & Locale
SETLAYOUT=$(locale |grep LANG=|cut -d "=" -f 2 |cut -d "_" -f 1)
SETLANG=$(locale |grep LANG=)
setxkbmap -layout $SETLAYOUT
echo "$SETLANG" > /etc/locale.conf

######
# make more space available so we can install new software while running

# get free mem info (we will not use % of free ram because it could make problems later)
AVAILMEM=$(cat /proc/meminfo |grep MemFree| egrep -o '[0-9]*')
# take 2/3 of the free ram and convert it to MB
MEMMB=$((AVAILMEM*2/3/1024))

# remount with the new size when the value is valid
if [ "$MEMMB" -ge 700 ];then
    sudo mount -o remount,size=${MEMMB}m /run/archiso/cowspace
fi

# check if we run in persistent mode or not and unmount /tmp if RAM less than required min
for opt in $(cat /proc/cmdline);do
        if [ "${opt%=*}" == "cow_label" ] && [ "$MEMMB" -lt 1024 ];then
            cp -a /tmp/* /var/tmp/
            sudo umount -l /tmp
            sudo mv /var/tmp/* /tmp/
        fi
done

