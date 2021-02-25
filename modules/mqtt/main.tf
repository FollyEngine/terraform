

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

resource "null_resource" "mqtt_homie_conf" {
  depends_on = [null_resource.mqtt ]
  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.ip_address
    password = var.initial_password
  }

  # https://github.com/Christian-Me/node-red-contrib-home/tree/master/Mosquitto
  provisioner "file" {
    content     = <<EOT
max_queued_messages 1000
queue_qos0_messages true
autosave_interval 1800
persistence true
persistence_file mosquitto.db
EOT
    #yeah, if only there was a "sudo flag"
    #destination = "/etc/mosquitto/conf.d/homie.conf"
    destination = "/tmp/homie.conf"
  }
}

resource "null_resource" "mqtt_homie_conf_install" {
    depends_on = [null_resource.mqtt_homie_conf ]

  connection {
    type = "ssh"    
    user = var.initial_user
    host = var.ip_address
    password = var.initial_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/homie.conf /etc/mosquitto/conf.d/homie.conf",
      "sudo systemctl restart mosquitto",
    ]
  }
}