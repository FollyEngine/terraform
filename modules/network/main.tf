

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

resource "null_resource" "setupnetwork" {
  #name = "${var.host_name}-docker"

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.host_name
    password = var.initial_password
  }

  # enable wifi, set the country=AU
  provisioner "remote-exec" {
    inline = [
      "if ! sudo grep zzcountry /etc/wpa_supplicant/wpa_supplicant.conf; then echo country=\"AU\" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf; fi",
      "sudo /sbin/wpa_cli -i wlan0 reconfigure",
      "sudo rfkill unblock wlan",
    ]
  }
}
