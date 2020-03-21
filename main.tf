

# module "lastpass" {
#   source  = "github.com/nrkno/terraform-provider-lastpass"
#   #version = "2.0.0"
#   # insert the 4 required variables here
#}

variable "lastpass_username" {}
variable "lastpass_password" {}

provider "lastpass" {
    version = "0.4.2"
    username = var.lastpass_username
    password = var.lastpass_password
}

# find the id of your secret using `lpass ls <name>`
data "lastpass_secret" "mqtt" {
    #name = "mqtt"
    id = "8934492033401515883"
}

output "custom_field" {
    //value = data.lastpass_secret.mqtt.custom_fields.host
    value = data.lastpass_secret.mqtt.username
}