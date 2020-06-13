# What it takes to build a Folly base station

## Hardware components

somewhere in the order of $600 each, plus extra meshAP's, network switch etc

1. Raspberry Pi 4 (4GB- $102), (2GB - $75)
2. RPi usb-c power adapter ($15)
3. 7 inch touch screen ($200)
4. 7 inch touch screen case ($45)
5. sd-card ($) **TODO - look at USB boot and usb flash**
6. Ubiquiti mesh AP and its poe power ($200)
7. double adaptor (or more)
7. a usb network adapter or USB mobile phone connection
  * I'd like to be able to use the dashboard to reconfigure the rpi wifi to connect to the local wifi
8. 2 or 3 network cables ($50) depending on length

if you're going to use 3 or 4 mesh ap's, then you could get the 60W unifi 8 port switch for $215, and buy the 5xmesh ap set for $800 (no poe adapters)
or, the $70 nanoswitch could simplify 3 ap setups... https://www.mwave.com.au/product/ubiquiti-nanoswitch-outdoor-4port-poe-passthrough-switch-ac14841
_but_ you need to buy a separate hight power POE power adapter (~$25)

interestingly, element14 has possibly better prices atm - 

## Building the hardware

(add step by step and photos)

## Softare

1. Docker
2. Unifi controller in a container
3. pi-hole / dnsmasq
3. some kind of database that can cope with power outages
  * look at 
  * https://forum.cockroachlabs.com/t/cockroach-on-the-raspbery-pi-3-64-bit/1246
  * https://www.raspberrypi.org/forums/viewtopic.php?t=200748
4. node-red
6. mqtt
5. logging / monitoring?
6. something to allow edge remote mgmt
  * wireguard?
  * portainer
7. dashboard, and displaying it on the screen
  * need a password? or some way to lock the screen....


## and how to install the software using the terraform bits in this repo

## Major bits that need work

  1 how to make the touchscreen node-red more useful
    * THE DATABASE - mongo / etc were terrible @ woodford when we lots power
    * screen lock!
    * use it, and an onscreen KB to configure the rpi wifi to use it to route to the net
      * https://flows.nodered.org/flow/c3c7a393b05f6383b888bdee39aa5fa5 ??
    * make the dashboard have links to the unifi controller, pi hole, and other monitoring sw
    * wireguard / portainer
    * mqtt protocol - its currently whatever worked for what i needed at the time
      * https://homieiot.github.io/specification/# ??
      * https://flows.nodered.org/node/node-red-contrib-homie-convention
      * 
