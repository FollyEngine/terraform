#!/bin/bash -e

# This script is used to get us to the point where we can use terraform to configure the pi
# running from USB


IP="$1"

if [[ "$IP" == "" ]]; then
    echo
    echo "need to add remote-IP address of the rpi you're updating"
    echo
    echo "or run the script as $0 local-rpi"
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
    # TODO: add key, don't over-write
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

if ! vcgencmd bootloader_config | grep BOOT_ORDER=0xf214; then
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
    echo "and once booted, run $0 <rpi addess> again, to continue boostrap"

    sudo halt

    exit
fi

USBDRIVE=/dev/sda
ROOTDEV=$(mount | grep "on / " | cut -d ' ' -f 1)

if [[ "${ROOTDEV}" == "${USBDRIVE}"* ]]; then
    echo "I think we've booted from USB, setting up the rest.."

    if [[ "$(hostname)" == "raspberrypi" ]]; then
        echo "SET THE HOSTNAME"

        read -p "enter new hostname (a-z0-9 only): " NAME
        sudo hostnamectl set-hostname ${NAME}

        echo "REBOOTING to set hostname, please"
        echo "and once booted, run $0 <rpi addess> again, to continue boostrap"

        sudo reboot --reboot
        exit
    fi

    sudo apt-get install apt-transport-https
    curl https://pkgs.tailscale.com/stable/raspbian/buster.gpg | sudo apt-key add -
    curl https://pkgs.tailscale.com/stable/raspbian/buster.list | sudo tee /etc/apt/sources.list.d/tailscale.list

    sudo apt-get update
    sudo apt-get install tailscale

    sudo tailscale up
fi

echo "SETUP complete, the rpi should now boot from USB"