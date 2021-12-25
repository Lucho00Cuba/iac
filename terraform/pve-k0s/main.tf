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

resource "proxmox_lxc" "k0s" {
  count        = 3
  target_node  = var.target_node
  hostname     = "${var.hostname}-${count.index}"
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = false

  #features {
  #  nesting = true
  #  keyctl  = true
  #}

  // Terraform will crash without rootfs defined
  rootfs {
    storage = var.storage
    size    = var.size
  }

  memory = "4096"
  swap = "512"
  cpuunits = "2048"

  network {
    name    = "eth0"
    bridge  = "vmbr0"
    ip      = "192.168.0.10${count.index}/24"
    gw      = "192.168.0.1"
  }

  ssh_public_keys = <<-EOT
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/eUkDcjJJLLOg0liI+xmdtCU61CZMCz4j4nNqF0qMxrBaR7WB3brCdDeusbMjWFUN7ZeltF0sKAfByOV9BRFrRTSEk8LMJkYgpghuCt2nF7aItJrssxKm/6ZjWZfQMcBmMPSxNBERx4csS5vRODDD6oCmBngMqm5b5ygEZ/SUEG3H+CsEokIMspZYXcsdaUeXVvmhcXCT87SpYWYPYXs/EhlTv6dcCkA+4z5c3zm95D87MQszLRdTGe1BY3uWcSflF1b9fOhOO3RMhTu7K4Ri5uQir/yrlgYit45yMEUHW8ly9jbFTYOpov0nzLaFwF4KRDDwZggIuPuIOAEzzTCi1B6la7/0HQl/4OzuF2wcuR0eWsWe1cx7/aftdPmCJu+bMEW56DLemqC/hOa6CeThFKTMAiSKvtjuj4sLA6kZ5lCl51Ifx1e6Ks8V6FclEEbHqClZLg/w/VB1kAeY1UVIGtQ/ZvqRMobcxu0FxPvz7STYYsTMdAwwukYFg7nc7IU= home@DESKTOP-KB42PTF
  EOT

  start = true

  connection {
    type      = "ssh"
    user      = "root"
    password  = var.password
    host      = "192.168.0.10${count.index}"
    private_key = "${file("/home/lucho/.ssh/k0s")}"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "wget https://gist.githubusercontent.com/Lucho00Cuba/0c44c4a2c283a1ffa2c135117bdfa352/raw/adbb3011f90c8e81a5eb20ec5f321d46ea47afc7/sources.list -O /etc/apt/sources.list",
      "mkdir -p /dev/kmsg",
      "echo 'mount --make-rshared /' > /etc/rc.local"
    ] 
  }

  # Fix LXC
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = "192.168.0.250"
      private_key = "${file("/home/lucho/.ssh/k0s")}"
    }
    when = create
    inline = [
      "echo 'lxc.cgroup.devices.allow = a' >> /etc/pve/lxc/${element(split("/", self.id),2)}.conf",
      "echo 'lxc.mount.entry = /dev/kmsg dev/kmsg none defaults,bind,create=file' >> /etc/pve/lxc/${element(split("/", self.id),2)}.conf",
      "echo 'lxc.apparmor.profile = unconfined' >> /etc/pve/lxc/${element(split("/", self.id),2)}.conf",
      "echo 'lxc.mount.auto: proc:rw sys:r var:rw' >> /etc/pve/lxc/${element(split("/", self.id),2)}.conf",
      "echo HECHO [*]"
    ]
  }

}

#resource "null_resource" "k0sctl" {
#  depends_on = [
#    proxmox_lxc.k0s
#  ]
#
#  provisioner "local-exec" {
#    command = "wget https://github.com/k0sproject/k0sctl/releases/download/v0.12.0/k0sctl-linux-x64 -O k0sctl && chmod +x k0sctl"
#  }
#
#  provisioner "local-exec" {
#    command = "/home/lucho/00/IaC/terraform/pve-k0s/k0sctl apply --config k0sctl.yaml"
#  }
#
#}

#mkdir -p /dev/kmsg
#lxc.cgroup.devices.allow = a
#lxc.mount.entry = /dev/kmsg dev/kmsg none defaults,bind,create=file
#lxc.apparmor.profile = unconfined
#terraform [action] --var-file terraform.tfvars -auto-approve