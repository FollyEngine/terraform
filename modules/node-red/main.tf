
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

data "docker_registry_image" "nodered" {
  //name = "nodered/node-red"
  name = "follyengine/nodered:latest"
}

resource "docker_image" "nodered" {
  name          = data.docker_registry_image.nodered.name
  pull_triggers = [data.docker_registry_image.nodered.sha256_digest]
}

// https://nodered.org/docs/getting-started/docker
resource "docker_container" "nodered" {
  name  = "nodered"
  image = docker_image.nodered.latest
  privileged = true

  restart = "always"
  ports {
    internal = 1880
    external = 1880
    ip = "0.0.0.0"
    protocol = "tcp"
  }
  # Don't persist the data, this will allow us to update the "management UI"
  # TODO: figure out how to do this optionally
  # mounts {
  #     target = "/data/"
  #     source = "nodered_data"
  #     type = "volume"
  # }
  mounts {
      target = "/etc/wpa_supplicant"
      source = "/etc/wpa_supplicant"
      type = "bind"
  }
  mounts {
      target = "/var/run/wpa_supplicant"
      source = "/var/run/wpa_supplicant"
      type = "bind"
  }

  env = [
    "TZ=Australia/Brisbane",
    "FLOWS=/data/flow.json",
    "NODE_RED_ENABLE_PROJECTS=true"
  ]

  #networks_advanced {
  #   name = "host"
  #}
  network_mode = "host"

  # only here to stop apply causing a "change" event
  working_dir       = "/usr/src/node-red"
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
