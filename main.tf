

# to add a new computer, create a new definition for what shoudl be installed in the ./computers dir, and add a reference to the module here
# the IP address should be a tailscale one

module "sven-screen1" {
  source = "./computers/sven-screen1"

  host_name = "sven-screen1"
  ip_address = "100.88.185.82"
  initial_user = "pi"
  initial_password = "raspberry"
}

