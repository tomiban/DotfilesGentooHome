#!/bin/bash

if [ -b "/dev/sdb" ]; then
    sdb="1";
fi
if [ -b "/dev/sdc" ]; then
    sdc="1";
fi
data1_read_sda2=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
data1_write_sda2=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
if [ "$sdb" ]; then
    data1_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
    data1_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
fi
if [ "$sdc" ]; then
    data1_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
    data1_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
fi
/usr/bin/sleep 0.5 &&
data2_read_sda2=$(/usr/bin/awk '/\<sda\>/{print $6}' /proc/diskstats);
data2_write_sda2=$(/usr/bin/awk '/\<sda\>/{print $10}' /proc/diskstats);
read_sda2=$((data2_read_sda2 - data1_read_sda2));
write_sda2=$((data2_write_sda2 - data1_write_sda2));
if [ "$sdb" ]; then
    data2_read_sdb=$(/usr/bin/awk '/\<sdb\>/{print $6}' /proc/diskstats);
    data2_write_sdb=$(/usr/bin/awk '/\<sdb\>/{print $10}' /proc/diskstats);
    read_sdb=$((data2_read_sdb - data1_read_sdb));
    write_sdb=$((data2_write_sdb - data1_write_sdb));
fi
if [ "$sdc" ]; then
    data2_read_sdc=$(/usr/bin/awk '/\<sdc\>/{print $6}' /proc/diskstats);
    data2_write_sdc=$(/usr/bin/awk '/\<sdc\>/{print $10}' /proc/diskstats);
    read_sdc=$((data2_read_sdc - data1_read_sdc));
    write_sdc=$((data2_write_sdc - data1_write_sdc));
fi
if [ "$1" == 'taskbar' ];then
    /usr/bin/printf "SSD|""R: $(/bin/echo "$((${read_sda2%%}/1024))MB/s") W: $(/bin/echo "$((${write_sda2%%}/1024))MB/s") ||\n";
else
    /usr/bin/printf "SSD|""R: $(/bin/echo "$((${read_sda2%%}/1024))MB/s") W: $(/bin/echo "$((${write_sda2%%}/1024))MB/s")\n";
fi

if [ "$sdb" ]; then
    /usr/bin/printf "HDD|""R: $(/bin/echo "$((${read_sdb%%}/1024))MB/s") W: $(/bin/echo "$((${write_sdb%%}/1024))MB/s")\n";
fi
if [ "$sdc" ]; then
    /usr/bin/printf "sdc|""R: $(/bin/echo "$((${read_sdc%%}/1024))MB/s") W: $(/bin/echo "$((${write_sdc%%}/1024))MB/s")\n";
fi
if [ "$1" != 'taskbar' ];then
    /usr/bin/printf "CPU Temp: ""$(/bin/echo "$(/usr/bin/sensors | /bin/grep 'Package id 0:' | /usr/bin/tail -1 | /usr/bin/cut -c 17-18)")""ºc";
fi
