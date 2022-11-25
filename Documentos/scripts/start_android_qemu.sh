#!/bin/bash
set -x
if [ "$EUID" -ne 0 ]; then
    /bin/echo "No root, no deal..";
    exit 1;
fi
killall adb &> /dev/null
start_bridge() {
    if [ -d /sys/class/net/android_bridge0 ]; then
        stop_bridge 2>/dev/null || true
    fi
    [ ! -d "/sys/class/net/android_bridge0" ] && ip link add dev android_bridge0 type bridge
    if [ ! -d "/run/meu_android" ]; then
        mkdir -p "/run/meu_android"
    fi
	ip addr add "192.0.0.1/30" dev android_bridge0
    ip link set dev android_bridge0 up
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -w -t nat -A POSTROUTING -s "192.0.0.1/30" ! -d "192.0.0.1/30" -j MASQUERADE
    iptables -w -I FORWARD -i android_bridge0 -j ACCEPT
    iptables -w -I FORWARD -o android_bridge0 -j ACCEPT
    touch "/run/meu_android/network_up"
}
stop_bridge() {
    if [ -d /sys/class/net/android_bridge0 ]; then
        ip addr flush dev android_bridge0
        ip link set dev android_bridge0 down
        iptables -w -D FORWARD -i android_bridge0 -j ACCEPT
        iptables -w -D FORWARD -o android_bridge0 -j ACCEPT
        iptables -w -t nat -D POSTROUTING -s 192.0.0.1/30 ! -d 192.0.0.1/30 -j MASQUERADE
        ls /sys/class/net/android_bridge0/brif/* > /dev/null 2>&1 || ip link delete android_bridge0
    fi
    rm -f "/run/meu_android/network_up"
}
if [ "$1" == 'start_bridge' ]; then
    start_bridge;
    exit;
elif [ "$1" == 'stop_bridge' ]; then
    stop_bridge;
    exit;
fi
if ! pgrep -f 'qemu-system-x86_64 -name Android'; then
    start_bridge
    for i in $(lsusb -d '1908:2310' | awk '{print $2}{print $4}' | tr -d ':'); do
        webcam+=("$i");
    done
    if [[ ${webcam[0]} && ${webcam[1]} ]]; then
        /bin/chgrp qemu /dev/bus/usb/"${webcam[0]}"/"${webcam[1]}";
    else
        echo "Webcam não detectada..";
        /bin/machinectl shell --uid=lucas .host /usr/bin/notify-send -u critical "QEMU: Webcam não detectada..";
        exit 1;
    fi
    su - lucas -s /bin/bash -c '
    export XDG_RUNTIME_DIR=/run/user/1000;
    export DISPLAY=:0; qemu-system-x86_64 \
                        -name Android \
                        -enable-kvm \
                        -machine q35,accel=kvm,vmport=off \
                        -m 2048 \
                        -smp 4 \
                        -cpu host \
                        -bios /usr/share/edk2-ovmf/OVMF_CODE.fd \
                        -nodefaults \
                        -audiodev pa,id=pa -audio pa,model=es1370 \
                        -usbdevice tablet \
                        -netdev bridge,id=hn0,br=android_bridge0 -device virtio-net-pci,netdev=hn0,id=nic1 \
                        -device qemu-xhci,id=xhci -device usb-host,hostdevice=/dev/bus/usb/'"${webcam[0]}"'/'"${webcam[1]}"' \
                        -device virtio-vga-gl,xres=640,yres=480 \
                        -display egl-headless -vnc :1 -k pt-br \
                        -drive file=/mnt/gentoo/.android/androidx86_hda.img,format=raw,if=virtio -object iothread,id=disk-iothread &
    sleep 1
    /usr/bin/vncviewer 127.0.0.1:1 -geometry=384x640 -PreferredEncoding=raw -RemoteResize -DotWhenNoCursor=on &'
    ok=0
    while pgrep vncviewer; do
        if [ "$ok" == '0' ]; then
            if ping 192.0.0.2 -w 1 -c 1; then
                adb connect 192.0.0.2:5555
                ok=1
            fi
        fi
        sleep 3;
    done
    pkill -f 'qemu-system-x86_64 -name Android'
    stop_bridge
else
    pkill -f 'qemu-system-x86_64 -name Android'
    pkill vncviewer
fi
