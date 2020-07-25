

variable "initial_user" {
    default = "pi"
}
variable "initial_password" {
    default = "raspberry"
}

resource "null_resource" "sven-screen1" {
  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = "100.88.185.82"
  }

  provisioner "file" {
    #TODO: this is an aweful workaround to https://github.com/hashicorp/terraform/issues/16330
    # source      = "~/.ssh/id_rsa.pub"
    # destination = "/home/pi/.ssh/authorized_keys"
    source      = "~/.ssh"
    destination = "/home/pi/.ssh"
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

