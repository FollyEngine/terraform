
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

provider "docker" {
  host = "ssh://${var.initial_user}@${var.ip_address}:22"
}


# set-inform http://non-tailscale_ip:8080/inform


#      "sudo docker run -it -d --restart=always --init --net=host -e TZ='Australia/Brisbane' 
#           -v /home/pi/unifi:/unifi --name unifi jacobalberty/unifi:5.12.66-arm32v7"

data "docker_registry_image" "unifi" {
  name = "jacobalberty/unifi:5.13.32-arm32v7"
}

resource "docker_image" "unifi" {
  name          = data.docker_registry_image.unifi.name
  pull_triggers = ["${data.docker_registry_image.unifi.sha256_digest}"]
}

# https://hub.docker.com/r/jacobalberty/unifi/tags
resource "docker_container" "unifi" {
  name  = "unifi"
  image = docker_image.unifi.latest

  restart = "always"
  network_mode = "host"     # simplifies adoption
  mounts {
      target = "/unifi/"
      source = "unifi_data"
      type = "volume"
  }


  # only here to stop apply causing a "change" event
  working_dir       = "/unifi"
    healthcheck {
            interval     = "0s" 
            retries      = 0 
            start_period = "5m0s"
            test         = [
                "CMD-SHELL",
                "/usr/local/bin/docker-healthcheck.sh || exit 1",
        ] 
            timeout      = "0s" 
    }
}