
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

#      "sudo docker run -it -d --restart=always --init --net=host -e TZ='Australia/Brisbane' 
#           -v /home/pi/unifi:/unifi --name unifi jacobalberty/unifi:5.12.66-arm32v7"
resource "docker_container" "unifi" {
  name  = "unifi"
  image = "jacobalberty/unifi:5.12.66-arm32v7"

  restart = "always"
  network_mode = "host"     # simplifies adoption
  mounts {
      target = "/unifi/"
      source = "unifi_data"
      type = "volume"
  }
}