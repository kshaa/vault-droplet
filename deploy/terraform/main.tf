# Use AWS S3 for Terragrunt state
# https://github.com/gruntwork-io/terragrunt/issues/212
terraform {
  backend "s3" {}
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Web server
resource "digitalocean_droplet" "droplet" {
  image  = "ubuntu-18-04-x64"
  name   = "${var.project_code}-london"
  region = "${var.region}"
  size   = "${var.droplet_size}"

  user_data = "${data.template_file.cloud_init.rendered}"
  volume_ids = ["${digitalocean_volume.volume.id}"]

  # Droplet itself is in a private network
  # See the "Floating IP" below for public access
  ipv6               = true
  private_networking = true
}

# Floating Ip
resource "digitalocean_floating_ip" "droplet_ip" {
  droplet_id = "${digitalocean_droplet.droplet.id}"
  region     = "${digitalocean_droplet.droplet.region}"
}

# Persistent volume
resource "digitalocean_volume" "volume" {
  region      = "${var.region}"
  # This name is used in chef recipes to mount the volume
  name        = "${var.project_code}-persist"
  size        = "${var.volume_size}"
  description = "persistent volume (db, docker images, etc.)"
}

# Domain setup
resource "digitalocean_domain" "droplet_domain" {
  # Terraform has a weird way to handle conditional resources - count
  count = "${var.domain_exists}"

  name = "${var.domain_name}"
  ip_address = "${digitalocean_floating_ip.droplet_ip.ip_address}"
}

# Initialisation user data template generation
data "template_file" "cloud_init" {
  template = "${file("${path.module}/init-cloud/cloud-init.yaml")}"

  vars {
    project_code = "${var.project_code}"
    source = "${var.source}"
    init_script = "${replace(file("${path.module}/init-cloud/init.sh"), "/(?m)^/", "      ")}"
    public_key = "${replace(file("${path.module}/id_rsa.pub"), "/(?m)^/", "        ")}"
  }
}

# Return the public (floating) droplet IP
output "droplet_ip" {
  value = "${digitalocean_floating_ip.droplet_ip.ip_address}"
}
