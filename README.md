# terraform - RPi configure for folly controller

Use Terraform to setup the RPi controller for FollyEngine

will result in:
* [ ] folly user setup
* [ ] pi user's password changed
* [x] <hostname>.folly.site DNS and *.<hostname>.folly.site DNS setup to point to tailscale IP
* [x] Docker installed and running
* [x] Tailscale installed and configured
* [ ] node-red installed
* [x] Unifi controller configured with initial Folly WiFi
* [ ] caddy with docker-proxy-plugin installed
  * [ ] set virtual.port for node-red, unifi, and pihole, and set them up nicely
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


## Curiosities

Would it be possible to PXE boot a new RPi (or network boot..), then have that auto-trigger Terraform...
