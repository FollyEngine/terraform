terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    unifi = {
      source = "paultyng/unifi"
      version = "0.19.2"
    }
    lastpass = {
      source = "nrkno/lastpass"
    }
  }
  required_version = ">= 0.13"
}
