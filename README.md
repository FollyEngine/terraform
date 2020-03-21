# terraform - RPi configure for folly controller

Use Terraform to setup the RPi controller for FollyEngine

will result in:
* [ ] folly user setup
* [ ] Docker installed and running
* [ ] Wireguard installed and configured
* [ ] node-red installed
* [ ] Unifi controller configured with initial Folly WiFi
* [ ] the 7inch screen working
* [ ] secrets, passords etc from Lastpass

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
3. `make init`
4. `make plan`
5. `make apply`


## Curiosities

Would it be possible to PXE boot a new RPi (or network boot..), then have that auto-trigger Terraform...