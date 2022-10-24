#!/bin/bash
command='alacritty -o window.dimensions.lines=13 window.dimensions.columns=55 -e /usr/bin/sudo /usr/bin/intel_gpu_top'
while :;do
    cpu_temp=$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)
    threshold=65
    if /bin/grep -q 'ENABLED=no' /etc/ufw/ufw.conf; then
        DATA='| C | Firewall desativado | | '$command' |';
    elif [ "$(pgrep easyeffects)" ]; then
        DATA='| A | EasyEffects ligado | | '$command' |'
        if [[ $cpu_temp -ge $threshold ]]; then
           DATA='| C | EasyEffects ligado \| CPU <b>'$cpu_temp'ºc</b> | | '$command' |'
        fi
    else
        if [ "$cpu_temp" -ge $threshold ]; then
            DATA='| C | CPU <b>'$cpu_temp'ºc</b> | | '$command' |'
        else
            DATA='| A | | | '$command' |'
        fi
    fi
    if [ "$DATA" != "$DATA_last" ];then
        /usr/bin/qdbus org.kde.plasma.doityourselfbar /id_953 org.kde.plasma.doityourselfbar.pass "$DATA"
        DATA_last="$DATA"
    fi
    sleep 3
done
