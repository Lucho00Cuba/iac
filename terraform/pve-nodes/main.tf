#https://github.com/wearespindle/terraform-provider-proxmox/blob/master/docs/resources/lxc.md

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.3"
    }
  }
}

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url = var.pm_api_url
    pm_password = var.pm_password
    pm_user = var.pm_user
    pm_otp = ""
}

# NODE's CLUSTER

resource "proxmox_lxc" "nodes" {
  count = 3
  target_node  = var.target_node
  hostname     = "${var.hostname}-${count.index}"
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = true

  features {
    nesting = true
    keyctl  = true
  }

  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.storage
    size    = var.size
  }

  memory = "4096"
  swap = "512"

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "192.168.0.10${count.index}/24"
    gw      = "192.168.0.1"
  }

  ssh_public_keys = <<-EOT
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRP2EGSSjFpv2KaqnYLzwWeQerhvBX2mpEoGu1QeLWDQ2WIN0ZI7LSSHwg0S0ZG9GUXrNqNrZV3hnlK4dxSMu/73gUh19virmaH6jSHhOumHAschymlDJ85F0Bg4i1HbZUiFIVRvTCkOKEjTZ7pTeyAWw0UpNALYx8Jd3cq//Bqn5sKG5augtwSGDWJOQXfb8uD5ysVTgr0qgVsHxGofT3RbrTf+/MK25NKGxJeBnMtYgPSijViMtnB78LtZX44BZb4N+wMUL6ojwGHT+2lIZDd4k6ZDPxyNjkcjsv0Xn3iEG8rfjHXNSQL9VL4U+hDSP8Ys3u+HIls9JGzmpzbnCWvwG5Ot5dUMJG35NfnoFUAL8O7f+ys8SMQCbDDRC5+BqGVBsL5GNuhnKYo+dAKnm/LeGl3LFeXupn44KdAtncms6miZCMAjmZ47NddGkrrIB4VHsc5i7wxiEWLcXcpjLk4r9XoZ9hAUCRxtvvXWvN8D6xNwTGA/3jVj7c7ytymEU= home@DESKTOP-KB42PTF
  EOT

  start = true
}

# NFS SERVER
#resource "proxmox_lxc" "nfs" {
#  target_node  = var.target_node
#  hostname     = "nfs-server"
#  ostemplate   = var.ostemplate
#  password     = var.password
#  unprivileged = true
#
#  features {
#    nesting = true
#    keyctl  = true
#  }
#  
#  // Terraform will crash without rootfs defined
#  rootfs {
#    storage = var.storage
#    size    = var.size
#  }
#
#  network {
#    name    = "eth0"
#    bridge  = "vmbr0"
#    ip      = "192.168.0.110/24"
#    gw      = "192.168.0.1"
#  }
#
#  ssh_public_keys = <<-EOT
#  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRP2EGSSjFpv2KaqnYLzwWeQerhvBX2mpEoGu1QeLWDQ2WIN0ZI7LSSHwg0S0ZG9GUXrNqNrZV3hnlK4dxSMu/73gUh19virmaH6jSHhOumHAschymlDJ85F0Bg4i1HbZUiFIVRvTCkOKEjTZ7pTeyAWw0UpNALYx8Jd3cq//Bqn5sKG5augtwSGDWJOQXfb8uD5ysVTgr0qgVsHxGofT3RbrTf+/MK25NKGxJeBnMtYgPSijViMtnB78LtZX44BZb4N+wMUL6ojwGHT+2lIZDd4k6ZDPxyNjkcjsv0Xn3iEG8rfjHXNSQL9VL4U+hDSP8Ys3u+HIls9JGzmpzbnCWvwG5Ot5dUMJG35NfnoFUAL8O7f+ys8SMQCbDDRC5+BqGVBsL5GNuhnKYo+dAKnm/LeGl3LFeXupn44KdAtncms6miZCMAjmZ47NddGkrrIB4VHsc5i7wxiEWLcXcpjLk4r9XoZ9hAUCRxtvvXWvN8D6xNwTGA/3jVj7c7ytymEU= home@DESKTOP-KB42PTF
#  EOT
#
#  start = true
#
#  provisioner "local-exec" {
#    command = "sleep 120 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i /home/lucho/00/IaC/ansible/hosts /home/lucho/00/IaC/ansible/nfs-server/nfs-docker-playbook.yml"
#  }
#}

#terraform [action] --var-file terraform.tfvars -auto-approve