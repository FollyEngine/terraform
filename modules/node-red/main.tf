
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

data "docker_registry_image" "nodered" {
  name = "nodered/node-red"
}

resource "docker_image" "nodered" {
  name          = data.docker_registry_image.nodered.name
  pull_triggers = ["${data.docker_registry_image.nodered.sha256_digest}"]
}

// https://nodered.org/docs/getting-started/docker
resource "docker_container" "nodered" {
  name  = "nodered"
  image = docker_image.nodered.latest

  restart = "always"
  ports {
    internal = 1880
    external = 1880
    ip = "0.0.0.0"
    protocol = "tcp"
  }
  mounts {
      target = "/data/"
      source = "nodered_data"
      type = "volume"
  }

  # only here to stop apply causing a "change" event
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