#!/bin/bash
/usr/bin/sleep 1
if [[ "$1" == "link" && ! -h "/etc/wireplumber/main.lua.d/51-alsa-disable.lua" ]];then
    if ! /usr/bin/pw-cli list-objects Node | /bin/grep -q -E 'combination|Simultaneous'
    then
        /usr/bin/pactl load-module module-combine-sink sink_name=combination-sink sink_properties=device.description=Combination-sink slaves=alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1,alsa_output.pci-0000_00_1b.0.analog-stereo channels=2
    fi
fi
# if ! /usr/bin/pactl list sources | /bin/grep -q 'Noise'; then
#     if /usr/bin/noisetorch -i 'alsa_input.usb-Generic_USB2.0_PC_CAMERA-02.pro-input-0'; then
#         /usr/bin/sleep 0.5;
#         /usr/bin/pactl set-default-source 'NoiseTorch Microphone for USB2.0 PC CAMERA'
#     fi
# fi
