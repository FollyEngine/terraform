
# state stored in https://app.terraform.io/app/folyengine/workspaces
#TODO: how to move this to a single common location...

terraform {
    # backend "remote" {
    #     hostname = "app.terraform.io"
    #     organization = "folyengine"
    #     workspaces {
    #         #set from terraform init -backend-config=state.hcl
    #         #name = "auth-folly-engine"
    #         #can set a prefix="something"
    #     }
    # }
  required_providers {
    lastpass = {
      source = "nrkno/lastpass"
      version = "0.5.2"
    }
  docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.5.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.0.0"
    }
  }
  required_version = ">= 0.13"
}