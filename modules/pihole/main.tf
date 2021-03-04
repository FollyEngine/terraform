
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

data "docker_registry_image" "pihole" {
  name = "pihole/pihole:latest"
}

resource "docker_image" "pihole" {
  name          = data.docker_registry_image.pihole.name
  pull_triggers = [data.docker_registry_image.pihole.sha256_digest]
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
    "ServerIP=${var.ip_address}",
    
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

  # only here to stop apply causing a "change" event
    healthcheck {
        interval     = "0s" 
        retries      = 0 
        start_period = "0s"
        test         = [
            "CMD-SHELL",
            "dig +norecurse +retry=0 @127.0.0.1 pi.hole || exit 1",
        ] 
        timeout      = "0s"
    }
}

// TODO: can configure dnsmasq using a file that goes into /etc/dnsmasq.d/
resource "null_resource" "pihole_custom_dns" {
  depends_on = [ docker_container.pihole ]

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.host_name
    password = var.initial_password
  }

  # TODO: expand the fs, setup wifi, do all the things

  provisioner "remote-exec" {
    inline = [
      <<-EOF
      if docker exec -it pihole grep "10.11.11.1 mqtt" /etc/pihole/custom.list ; then
        return
      fi
      docker exec -it pihole sh -c 'echo "10.11.11.1 mqtt" >> /etc/pihole/custom.list'
EOF
    ]
  }
}
