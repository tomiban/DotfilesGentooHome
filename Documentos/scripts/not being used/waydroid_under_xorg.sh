#!/bin/bash
if [ "$(systemctl is-active waydroid-container.service)" == 'active' ];then
    killall -9 weston &> /dev/null;
    sudo systemctl stop waydroid-container.service;
    exit
fi
killall -9 weston &> /dev/null;
sudo systemctl restart waydroid-container.service;
if [ -z "$(pgrep weston)" ]; then
    weston --xwayland &> /dev/null &
fi
sleep 2;
export XDG_SESSION_TYPE='wayland';
export DISPLAY=':1';
alacritty -e '/usr/bin/waydroid show-full-ui' &> /dev/null &
while [ -n "$(pgrep weston)" ];do
    sleep 1;
done
sudo systemctl stop waydroid-container.service;
