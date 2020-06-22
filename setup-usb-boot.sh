#!/bin/bash -ex

# This script is used to get us to the point where we can use terraform to configure the pi
# running from USB


IP="$1"

if [[ "$IP" == "" ]]; then
    echo "need to add IP address of the rpi you're updating"
    exit
fi

if [[ "$IP" != "local-rpi" ]]; then
        # TODO: if the script's not there, scp it, then upgrade&reboot


    # sleep 30

    scp ./setup-usb-boot.sh pi@${IP}:/home/pi/

    ssh pi@${IP} sudo ./setup-usb-boot.sh local-rpi

    # TODO: work out how often it needs to run...
    exit
fi

if [[ ! -f /home/pi/.ssh/authorized_keys ]]; then
    ssh pi@${IP} mkdir -p /home/pi/.ssh/
    scp ~/.ssh/id_Apr2020.pub pi@${IP}:/home/pi/.ssh/authorized_keys
    ssh pi@${IP} sudo apt update
    ssh pi@${IP} sudo apt upgrade -yq
    ssh pi@${IP} sudo reboot
fi

if ! grep  stable /etc/default/rpi-eeprom-update; then
    # the real config
    echo 'FIRMWARE_RELEASE_STATUS="stable"' >/etc/default/rpi-eeprom-update
    sudo rpi-eeprom-update -a
    sudo reboot
fi

# print eeprom state
vcgencmd bootloader_version
vcgencmd bootloader_config

# now set USB BOOT, eject sd-card, insert usb, and reboot

#root@raspberrypi:/home/pi# rpi-eeprom-config /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-06-15.bin

# see https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md
# BOOT_ORDER=0xf241 == sd, usb, network, repeat
# BOOT_ORDER=0xf214 == usb, sd, network, repeat

cat > bootconf.txt <<HERE
[all]
BOOT_UART=0
WAKE_ON_GPIO=1
POWER_OFF_ON_HALT=1
DHCP_TIMEOUT=45000
DHCP_REQ_TIMEOUT=4000
TFTP_FILE_TIMEOUT=30000
ENABLE_SELF_UPDATE=1
DISABLE_HDMI=0
BOOT_ORDER=0xf214
HERE

rpi-eeprom-config --out pieeprom-new.bin --config bootconf.txt /lib/firmware/raspberrypi/bootloader/stable/pieeprom-2020-06-15.bin

sudo rpi-eeprom-update -d -f ./pieeprom-new.bin

echo "REMOVE the SDCARD, and install a bootable USB drive into the RPI"

sudo halt

