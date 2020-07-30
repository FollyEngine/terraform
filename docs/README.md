# What it takes to build a Folly base station

Make sure you have the follyengine@gmail.com Tailscale vpn setup on your desktop

- https://tailscale.com/kb/1017/install
- [ ] TODO: work out DNS...

## Hardware components

### lcd version, with node-red on rpi

somewhere in the order of \$600 each, plus extra meshAP's, network switch etc

1. Raspberry Pi 4 (4GB- $102), (2GB - $75)
2. RPi usb-c power adapter (\$15)
3. 7 inch touch screen (\$200)
4. 7 inch touch screen case (\$45)
5. boot media
   - USB boot and usb flash (sandisk ultra fit usb 3.1 32GB ~\$15?) - https://www.amazon.com.au/gp/product/B077VXV323/ref=crt_ewc_img_huc_1?ie=UTF8&psc=1&smid=A1E8JZNQ4REMVH
6. Ubiquiti mesh AP and its poe power (\$200)
7. double adaptor (or more)
8. a usb network adapter or USB mobile phone connection
   1. I'd like to be able to use the dashboard to reconfigure the rpi wifi to connect to the local wifi
9. 2 or 3 network cables (\$50) depending on length

if you're going to use 3 or 4 mesh ap's, then you could get the 60W unifi 8 port switch for $215, and buy the 5xmesh ap set for $800 (no poe adapters)
or, the $70 nanoswitch could simplify 3 ap setups... https://www.mwave.com.au/product/ubiquiti-nanoswitch-outdoor-4port-poe-passthrough-switch-ac14841
_but_ you need to buy a separate hight power POE power adapter (~$25)

interestingly, element14 has possibly better prices atm

### mini-folly-base-station (node-red and database on a laptop)

somewhere in the order of (\$300) each, plus extra meshAP's, network switch etc

1. pi zero (\$130)
   1. Raspberry Pi Zero W (\$30)
   2. Ethernet USB hub with micro-usb (\$35)
   3. RPi usb-a power adapter (\$20)
   4. FLIRC case (\$25)
   5. 16GB sdcard (\$20)
2. OR pi4 2GB (\$155) <------------ makes more sense
   1. Raspberry Pi 4 (2GB - \$75)
   2. RPi usb-c power adapter (\$15)
   3. Argon ONE case (\$50)
   4. USB boot and usb flash (sandisk ultra fit usb 3.1 32GB ~\$15?)
3. Ubiquiti mesh AP and its poe power (\$170)
4. 240v double adaptor (or more)
5. a usb network adapter or USB mobile phone connection
   1. I'd like to be able to use the dashboard to reconfigure the rpi wifi to connect to the local wifi
6. 2 or 3 network cables (\$50) depending on length

## Building the hardware

(add step by step and photos)

## Software

0. Prepare the new USB flash drive (write script to do this):
   1. [ ] dd the latest image
   2. [ ] update the firmware on the image
   3. [ ] touch /boot/ssh
1. setup-usb-boot.sh to
   1. [x] bootstrap to booting from USB
   2. [x] set hostname
   3. [x] setup tailscale (wireguard vpn)
2. [x] Docker
3. [x] Unifi controller in a container
   1. [ ] automate the setup of the unifi controller - I'm doing it by hand atm (Folly, Fight)
4. [x] pi-hole / dnsmasq
   1. [1] fix the eth0-static-ip remote-exec
   2. [ ] figure out what mqtt ip address the esp's are set to
   3. [ ] add NAT rules for wan0 (telstra dongle) and rpi wifi
5. [x] mqtt
6. [x] node-red
   1. [ ] work out how to install extras...
   2. [ ] work out how to backup/restore/update from git...
   3. [ ] power on, power off, lcd on, lcd off
      1. [ ] backlight https://www.raspberrypi.org/forums/viewtopic.php?f=108&t=120968&start=25#p834085
      2. [ ] https://www.raspberrypi.org/forums/viewtopic.php?t=244425
      3. [ ] sudo sh -c 'echo "1" > /sys/class/backlight/rpi_backlight/bl_power'
      4. [ ] sudo sh -c 'echo "0" > /sys/class/backlight/rpi_backlight/bl_power'
      5. [ ] https://github.com/DougieLawson/backlight_dimmer
7. [ ] add info on how to use the rpi wifi
   1. [ ] using /boot
   2. [ ] using ssh
   3. [ ] using node-red
8. [ ] some kind of database that can cope with power outages
   1. https://forum.cockroachlabs.com/t/cockroach-on-the-raspbery-pi-3-64-bit/1246
   2. https://www.raspberrypi.org/forums/viewtopic.php?t=200748
9. [ ] logging / monitoring?
10. [ ] something to allow edge remote mgmt
11. [ ] portainer
12. [x] kiosk, autologin and displaying it on the screen
    1. [ ] brightness
    2. [ ] screen on and off control
    3. [ ]
13. [ ] need a password? or some way to lock the screen....
14. [x] figure out how to get the docker provisioner to not reprovision every apply
15. [ ] figure out why the remote-exec provisioner needs the ssh-passworkd, not a key...
16. [ ] consider https://github.com/pokusew/nfc-pcsc/issues/43 nfc card emulation to enable esp auto-config
    1. [ ] it'd be nice to not need a pre-determined ssid and passphrase, but to be random, and then to use an micro-nfc reader in each esp/device to find out the ssid and passphrase to use for that show
    2. [ ] and thus to auto-register that device into that show's node-red

## and how to install the software using the terraform bits in this repo

### Step1: configure the rpi 4 to boot from USB

Use a known good sd-card to boot, find its IP address, and then from your local computer, run

```
setup-usb-boot.sh <rpi-ip-address>
```

(if necessary, you can run it from the rpi, but that doesn't setup the ssh keys)

### Step2: remove the sdcard, and put in the USB with raspberryOS on it

1. Set the hostname, and
2. Boot from USB, then run `setup-tailscale.sh`

### Step3: use the new hostname in terraform

1. run `make build`
2. run `make start`
3. run `make init`
4. Add host, and its tailscale ip to xxx.tf,
5. run `make plan` to confirm that nothing untoward is about to happen, then
6. run `make apply`

## Major bits that need work

- [ ] **URGENT** setup rules so the folly base stations can't get out to other nodes, only the user desktops can get into the base stations
- [ ] how to make the touchscreen node-red more useful
- [ ] THE DATABASE - mongo / etc were terrible @ woodford when we lots power
- [ ] screen lock!
- [ ] use it, and an onscreen KB to configure the rpi wifi to use it to route to the net
  - https://flows.nodered.org/flow/c3c7a393b05f6383b888bdee39aa5fa5 ??
- [ ] make the dashboard have links to the unifi controller, pi hole, and other monitoring sw
- [ ] tailscale
- [ ] portainer
- [ ] mqtt protocol - its currently whatever worked for what i needed at the time
  - https://homieiot.github.io/specification/# ??
  - https://flows.nodered.org/node/node-red-contrib-homie-convention
  -
