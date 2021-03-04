
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

# set-inform http://non-tailscale_ip:8080/inform


#      "sudo docker run -it -d --restart=always --init --net=host -e TZ='Australia/Brisbane' 
#           -v /home/pi/unifi:/unifi --name unifi jacobalberty/unifi:5.12.66-arm32v7"

data "docker_registry_image" "unifi" {
#  name = "jacobalberty/unifi:5.13.32-arm32v7"
  name = "jacobalberty/unifi:latest"
}

resource "docker_image" "unifi" {
  name          = data.docker_registry_image.unifi.name
  pull_triggers = [data.docker_registry_image.unifi.sha256_digest]
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

//$ lpass show 2353786631527707497
//follyengine-wifi [id: 2353786631527707497]
//Username: Folly
//Password: 
data "lastpass_secret" "folly_wifi" {
   id = "2353786631527707497"
}

## TODO: the following can only be used _after_ the unifi container exists, because terraform is missing a depends_on (not that that fixes it either, but \o/)
// https://registry.terraform.io/providers/paultyng/unifi/latest/docs
provider "unifi" {
  #depends_on = [docker_container.unifi ]


  username = data.lastpass_secret.folly_wifi.username # optionally use UNIFI_USERNAME env var
  password = data.lastpass_secret.folly_wifi.password # optionally use UNIFI_PASSWORD env var
  api_url  = "https://${var.ip_address}:8443"  # optionally use UNIFI_API env var

  # you may need to allow insecure TLS communications unless you have configured
  # certificates for your controller
  allow_insecure = true //var.insecure # optionally use UNIFI_INSECURE env var

  # if you are not configuring the default site, you can change the site
  # site = "foo" or optionally use UNIFI_SITE env var
}

data "unifi_user_group" "default" {
}

# resource "unifi_wlan" "wifi" {
#   name          = data.lastpass_secret.folly_wifi.username
#   //vlan_id       = 10
#   passphrase    = data.lastpass_secret.folly_wifi.password
#   user_group_id = data.unifi_user_group.default.id
#   security      = "wpapsk"
#   ap_group_ids = []
# }