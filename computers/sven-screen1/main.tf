

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

module "sshkeys" {
  source = "../../modules/sshkeys"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
  initial_password = var.initial_password
}

module "dockerd" {
  source = "../../modules/dockerd"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
}

# see https://100.88.185.82:8443
module "unifi-controller" {
  source = "../../modules/unifi-controller"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
}

module "pihole" {
  source = "../../modules/pihole"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
  initial_password = var.initial_password
}

module "mqtt" {
  source = "../../modules/mqtt"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
  initial_password = var.initial_password
}

module "node-red" {
  source = "../../modules/node-red"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
  initial_password = var.initial_password
}

// Kiosk mode - for pi's with screens
module "kiosk" {
  source = "../../modules/kiosk"

  host_name = "sven-screen1"
  ip_address = var.ip_address
  initial_user = var.initial_user
  initial_password = var.initial_password
}

resource "null_resource" "eth0-static-ip" {
  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = var.ip_address
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

