

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

resource "null_resource" "dockerd" {
  #name = "${var.host_name}-docker"

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.ip_address
  }

  # TODO: expand the fs, setup wifi, do all the things

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -yq",
      "sudo apt install vim-tiny curl",
      // don't run it again - i guess each of these should be separate resources..
      "if ! which docker; then curl https://get.docker.com | sh; fi",
      "sudo usermod -aG docker pi",
    ]
  }
}