terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "demo"
  password    = "supersecret"
  auth_url    = "http://192.168.0.200/identity"
  region      = "RegionOne"
}

# Variables
variable "keypair" {
  type    = string
  default = "Lucho"   # name of keypair created 
}

variable "network" {
  type    = string
  default = "private" # default network to be used
}

variable "security_groups" {
  type    = list(string)
  default = ["default"]  # Name of default security group
}

# Create an instance
resource "openstack_compute_instance_v2" "server" {
  name            = "server"  #Instance name
  image_id        = "1b9f30fe-893c-4f1f-9398-2206e842a27b"
  flavor_id       = "d2"
  key_pair        = var.keypair
  security_groups = var.security_groups
  user_data       = file("pv.sh")

  network {
    name = var.network
  }
}

resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.server.id
}

# Output VM IP Address
output "LOGS" {
 value = "LOCAL: ${openstack_compute_instance_v2.server.access_ip_v4}\nGLOBAL: ${openstack_networking_floatingip_v2.fip1.address}\nNAME: ${openstack_compute_instance_v2.server.name}"
}