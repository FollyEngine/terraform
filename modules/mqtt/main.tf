

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

resource "null_resource" "mqtt" {

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.ip_address
    password = var.initial_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt install -yq mosquitto mosquitto-clients",
    ]
  }
}