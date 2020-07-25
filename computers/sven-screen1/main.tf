

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
  initial_password = var.initial_password
}

