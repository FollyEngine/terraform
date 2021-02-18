# terraform - RPi configure for folly controller

Use Terraform to setup the RPi controller for FollyEngine

will result in:
* [ ] folly user setup
* [ ] pi user's password changed
* [x] <hostname>.folly.site DNS and *.<hostname>.folly.site DNS setup to point to tailscale IP
* [x] Docker installed and running
* [x] Tailscale installed and configured
* [x] mqtt server (on host)
* [x] node-red installed (in container) port 1880
  * [ ] replace port publishing with caddy
  * [ ] install basic monitoring and wifi setting flows for node-red
* [x] pihole instaled (in container) port 80
  * [ ] blah - no api / settings, need to use /etc/pihole/setupVars.conf ?
  * [ ] til then, need to hand configure DHCP - 10.11.11.100 -> 10.11.11.200, router 10.11.11.1
  * [ ] need to put the website on a different port, or work out how to do the DHCP server using caddy?
* [x] Unifi controller configured with initial Folly WiFi (in container) port 8080
  * [ ] Auto configure it with password, and Folly WIFI network
    * sadly, needs manual intervention
  * [ ] move to caddy
  * [ ] figure out auth
* [ ] caddy with docker-proxy-plugin installed
  * [ ] set virtual.port for node-red, unifi, and pihole, and set them up nicely
  * [ ] see if we can disable app auth and use caddy-auth
* [x] the 7inch screen working
* [x] secrets, passwords etc from Lastpass
* [ ] terraform state stored in the terraform cloud
  * [ ] separate out each host into its own workspace
  * [ ] figure out how to make seeing the state&plan for each obvious - some admin grafana vis?

## How to use

0. Pre-req's
   * https://github.com/nrkno/terraform-provider-lastpass
   * sudo apt-get install lastpass-cli - oh, actually, this needs to be inside the terraform image bbiab
1. Flash the SDCard with XXX
   * Do we need to enable ssh?
   * starting with Raspbian Buster Lite - 2020-02-13
   * `fdisk -l`
   * `dd if=2020-02-13-raspbian-buster-lite.img of=/dev/mmcblk0 bs=4096`
   * `sync`
   * remove sdcard, and put back in to re-init partition table cache (may not be needed anymore?)
   * `mount /dev/mmcblk0p1 /mnt`
   * `touch /mnt/ssh`
   * `umount /mnt`
   * `sync`
   * remove sdcard, and put in pi & boot...
   * find ip address, then `ssh pi@<ip address>`, default password ~ `raspberry`
2. Boot, and get IP Address
3. `make start`
4. `make init`
5. `make plan`
6. `make apply`
7. Then attach the unifi AP to the pi built in network port, and something elsewhere to get internet (could also cfg the pi's wifi..)
   1. ...


## Curiosities

Would it be possible to PXE boot a new RPi (or network boot..), then have that auto-trigger Terraform...
