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
resource "proxmox_lxc" "k3s" {
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

  memory = "4096"
  swap = "0"
  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.storage
    size    = var.size
  }

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "192.168.0.10${count.index}/24"
    gw      = "192.168.0.1"
  }

  // KEY DOCKER
  ssh_public_keys = <<-EOT
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOrB9AyQY07APxnqHwHmT8JS4bhbY6bvEJNpLKtc0M78CPjbZlzkDovrTmhcZe16B+EXjXYxlOI2D2SyYxLwzZ75K8CcVx5NiQTa7O/B6pvdLRjSYzhMsGVzagmZdSfqzGgiByuDl4PXHcx+vfr68XbrjnA3ATxsPlYdAw2qF/z5BzKsnESvGKKjV8fFFKlAeeaAXj8jGWHhK8StfUYOMaJ+2YfdAXuNQiwpWFAlHK+ufKHt9BpDgc1OS4rT9YhevYYC/jS1dKdZthYX7fA/isTqdH2UZxV5rfOybraGuUhp77DwzxvRi6BGqGZi+9QxbN6xCyGVSLWvysCn1FcJYBOJfu7xzX0aGiDLKGRmFnNUOEEXwxtFp1XEK4Xahm0fax/K5OnKujEeBimnZLZEca9EyAm4n8z8Al5QoGLHUeU0lSKpE8lffQx+2V9+bt6Re0JlfQ/6RMRgmlKD17CAAjUIgPQx6yjQORimpT4Arr6RU1u2sisg5Fx9BXwRkkgCtkkjtQiSGcy7CUnq5lIx2u4K3qXMPaotLAdHDuWV9h3zjJtPRNySStbn9mvXYdrRkVDht5874ECPzXXVaeHZ7bueUwrl09dIwkEKzfPx1VwmYdETr8yoCqMxweNexmGALYu5FJfrP9eX/SCgGV9BouLCZTdBN/euqnKqEpyXCofw== lucho@cloud
  EOT

  start = true

}

resource "null_resource" "docker" {
  depends_on = [
    proxmox_lxc.k3s
  ]
  // Docker
  provisioner "local-exec" {
    command = "sleep 150 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key /home/lucho/.ssh/docker -u root -i /home/lucho/00/IaC/ansible/hosts /home/lucho/00/IaC/ansible/docker/docker-playbook.yml"
  }
}

#terraform [action] --var-file terraform.tfvars -auto-approve