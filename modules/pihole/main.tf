
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

provider "docker" {
  host = "ssh://${var.initial_user}@${var.ip_address}:22"
}

data "docker_registry_image" "pihole" {
  name = "pihole/pihole:latest"
}

resource "docker_image" "pihole" {
  name          = data.docker_registry_image.pihole.name
  pull_triggers = ["${data.docker_registry_image.pihole.sha256_digest}"]
}

#https://hub.docker.com/r/pihole/pihole/
#https://github.com/pi-hole/docker-pi-hole/blob/master/docker_run.sh
resource "docker_container" "pihole" {
  name  = "pihole"
  image = docker_image.pihole.latest

  restart = "always"
  network_mode = "host"     // simplifies adoption

  env = [
    "TZ=Australia/Brisbane",
    "VIRTUAL_HOST=pi.hole",
    "PROXY_LOCATION=pi.hole",
    "ServerIP=100.88.185.82",
    
    "WEBPASSWORD=${var.initial_password}",
    "DNS1=127.0.0.1",
    "DNS2=1.1.1.1",

    "DNSMASQ_LISTENING=eth0"  // the main rpi ethernet
  ]

  //-v "$(pwd)/etc-pihole/:/etc/pihole/" \
  //-v "$(pwd)/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
  mounts {
      target = "/etc/pihole/"
      source = "etc-pihole"
      type = "volume"
  }
  mounts {
      target = "/etc/dnsmasq.d/"
      source = "etc-dnsmasqd"
      type = "volume"
  }

  // need NET_ADMIN for dhcp
  capabilities {
    add  = ["NET_ADMIN", "CAP_SYS_NICE"]
  }
}

// TODO: can configure dnsmasq using a file that goes into /etc/dnsmasq.d/

