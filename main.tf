

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

resource "lastpass_secret" "mydb" {
    name = "mqtt"
}

