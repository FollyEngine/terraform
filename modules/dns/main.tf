
variable "host_name" {
  description = "The name to use for host_name"
  type        = string
}
variable "ip_address" {
  description = "The ip to use for host_name"
  type        = string
}

// lpass show --notes 3167287270339421105
data "lastpass_secret" "dotoken" {
   # DREAMHOST_API_KEY
   id = "3167287270339421105"
}

provider "digitalocean" {
  token = data.lastpass_secret.dotoken.note
}

data "digitalocean_domain" "follysite" {
  name = "folly.site"
}

# Add a record to the domain
resource "digitalocean_record" "host" {
  domain = data.digitalocean_domain.follysite.name
  type   = "A"
  name   = var.host_name
  value  = var.ip_address
  ttl    = 60
}

# Add a record to the domain
resource "digitalocean_record" "wildcard" {
  domain = data.digitalocean_domain.follysite.name
  type   = "A"
  name  = "*.${var.host_name}"
  value  = var.ip_address
  ttl    = 60
}


# Output the FQDN for the record
output "fqdn" {
  value = digitalocean_record.host.fqdn
}
