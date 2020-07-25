

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

resource "null_resource" "sshkeys" {
  #name = "${var.host_name}-sshkeys"

  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = var.ip_address
  }

  provisioner "file" {
    #TODO: this is an aweful workaround to https://github.com/hashicorp/terraform/issues/16330
    # source      = "~/.ssh/id_rsa.pub"
    # destination = "/home/pi/.ssh/authorized_keys"
    source      = "~/.ssh"
    destination = "/home/pi/.ssh"
  }
}

resource "null_resource" "ssh_remember1" {
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${var.ip_address} >> ~/.ssh/known_hosts"
  }
  depends_on = [null_resource.sshkeys]
}
