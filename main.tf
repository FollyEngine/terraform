

variable "initial_user" {
    default = "pi"
}
variable "initial_password" {
    default = "raspberry"
}

resource "null_resource" "folly-screen1" {
  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = "10.10.10.143"
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
      //"curl https://get.docker.com | sh",
      "sudo usermod -aG docker pi",
    ]
  }
}

resource "null_resource" "folly-screen1_unifi" {
  depends_on = [null_resource.folly-screen1]
  connection {
    type = "ssh"    
    user = var.initial_user
    password = var.initial_password
    host = "10.10.10.129"
  }

  provisioner "remote-exec" {
    inline = [
      # -p 8080:8080 -p 8443:8443 -p 3478:3478/udp -p 10001:10001/udp
      # user --net=host to simplify the adoption process
      "sudo docker run -it -d --restart=always --init --net=host -e TZ='Australia/Brisbane' -v /home/pi/unifi:/unifi --name unifi jacobalberty/unifi:5.12.66-arm32v7"
    ]
  }
}
