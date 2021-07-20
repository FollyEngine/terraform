#module "follybase1" {
  #source = "./computers/follybase1"
locals {
  host_name = "follybase1"
  ip_address = "100.101.66.56"
  initial_user = "pi"
  initial_password = "raspberry"
}

terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "follyengine"
        workspaces {
            #set from terraform init -backend-config=state.hcl
            name = "follybase1"
            #can set a prefix="something"
        }
    }
  required_providers {
  #   lastpass = {
  #     source = "nrkno/lastpass"
  #     version = "0.5.2"
  #   }
  docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
  #   digitalocean = {
  #     source = "digitalocean/digitalocean"
  #     version = "2.5.1"
  #   }
  #   null = {
  #     source = "hashicorp/null"
  #     version = "3.0.0"
  #   }
  }

  required_version = ">= 0.13"
}

module "sshkeys" {
  source = "../../modules/sshkeys"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
}

module "dns" {
  source = "../../modules/dns"

  host_name = local.host_name
  ip_address = local.ip_address
}

module "network" {
  source = "../../modules/network"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
}

module "dockerd" {
  source = "../../modules/dockerd"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
}

resource "local_file" "dockersock" {
  # HACK: depends_on for the helm provider
  # Passing provider configuration value via a local_file
  depends_on = [module.dockerd]
  content    = module.dockerd.dockersock
  filename   = "./terraform.tfstate.dockerd.dockersock"
}

provider "docker" {
//  host = "ssh://${local.initial_user}@${local.host_name}:22"
  //host = module.dockerd.dockersock
  host = local_file.dockersock.content
}

# see https://100.88.185.82:8443
module "unifi-controller" {
  source = "../../modules/unifi-controller"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user

  # depends_on = [
  #   module.dockerd,
  # ]
  providers = {
    docker = docker
  }
}

module "pihole" {
  source = "../../modules/pihole"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
  depends_on = [
    module.dockerd,
  ]
  providers = {
    docker = docker
  }
}

module "mqtt" {
  source = "../../modules/mqtt"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
}

module "node-red" {
  source = "../../modules/node-red"

  host_name = local.host_name
  ip_address = local.ip_address
  initial_user = local.initial_user
  initial_password = local.initial_password
}

module "portainer-agent" {
  source = "../../modules/portainer-agent"

  # host_name = local.host_name
  # ip_address = local.ip_address
  # initial_user = local.initial_user
  # initial_password = local.initial_password
}

resource "null_resource" "eth0-static-ip" {
  connection {
    type = "ssh"    
    user = local.initial_user
    password = local.initial_password
    host = local.ip_address
  }

  provisioner "remote-exec" {
    inline = [
    "echo \"interface eth0\" >> /etc/dhcpcd.conf",
    "echo \"   static ip_address=10.11.11.1/24\" >> /etc/dhcpcd.conf",
    "echo \"   nohook wpa_supplicant\" >> /etc/dhcpcd.conf",
    "sudo systemctl daemon-reload",
    "sudo service dhcpcd restart",
    "sudo sh -c \"echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf\"",
    "sudo iptables -t nat -A  POSTROUTING -o eth1 -j MASQUERADE",
    "sudo sh -c \"iptables-save > /etc/iptables.ipv4.nat\"",
    "sudo sh -c \"iptables-restore < /etc/iptables.ipv4.nat\""
    ]
  }
}

# need to set the dhcpserver on, and ip range
# gateway == 10.11.11.1

