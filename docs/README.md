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
2. OR pi4 2GB (\$135) <------------ makes more sense
   1. Raspberry Pi 4 (2GB - \$75)
   2. RPi usb-c power adapter (\$15)
   3. FLIRC case (\$30)
   4. USB boot and usb flash (sandisk ultra fit usb 3.1 32GB ~\$15?)
3. Ubiquiti mesh AP and its poe power (\$170)
4. double adaptor (or more)
5. a usb network adapter or USB mobile phone connection
   1. I'd like to be able to use the dashboard to reconfigure the rpi wifi to connect to the local wifi
6. 2 or 3 network cables (\$50) depending on length

## Building the hardware

(add step by step and photos)

## Software

1. setup-usb-boot.sh to
   1. [x] bootstrap to booting from USB
   2. [x] set hostname
   3. [x] setup tailscale (wireguard vpn)
2. [ ] terraform!
3. [ ] Docker
4. [ ] Unifi controller in a container
5. [ ] pi-hole / dnsmasq
6. [ ] some kind of database that can cope with power outages
   1. https://forum.cockroachlabs.com/t/cockroach-on-the-raspbery-pi-3-64-bit/1246
   2. https://www.raspberrypi.org/forums/viewtopic.php?t=200748
7. [ ] node-red
8. [ ] mqtt
9. [ ] logging / monitoring?
10. [ ] something to allow edge remote mgmt
11. [ ] portainer
12. [ ] dashboard, and displaying it on the screen
13. [ ] need a password? or some way to lock the screen....

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

1. Add host to xxx.tf, and run `make plan` to confirm that nothing untoward is about to happen, then
2. run `make apply`

## Major bits that need work

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
