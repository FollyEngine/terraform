terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    lastpass = {
      source = "nrkno/lastpass"
    }
  }
  required_version = ">= 0.13"
}
