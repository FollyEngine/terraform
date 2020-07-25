

variable "host_name" {
  description = "The name to use for host_name"
  type        = string
}

variable "ip_address" {
  description = "The ip address"
  type        = string
}

variable "initial_user" {
  description = "pi"
  type        = string
}

variable "initial_password" {
  description = "raspberry"
  type        = string
}

resource "null_resource" "kiosk-service" {
  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = var.ip_address
  }

  //https://die-antwort.eu/techblog/2017-12-setup-raspberry-pi-for-kiosk-mode/
  //https://desertbot.io/blog/raspberry-pi-touchscreen-kiosk-setup
  provisioner "file" {
    source      = "modules/kiosk/openbox-autostart"
    destination = "~/openbox-autostart"
    #destination = "/etc/xdg/openbox/autostart"
  }
}

// https://jonathanmh.com/raspberry-pi-4-kiosk-wall-display-dashboard/
resource "null_resource" "kiosk" {
  depends_on = [null_resource.kiosk-service]

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.ip_address
    password = var.initial_password
  }

  // used raspi-config to set autologin as `pi` to GUI
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -yq --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox lightdm chromium-browser",
      "sudo cp ./openbox-autostart /etc/xdg/openbox/autostart"
    ]
  }
}