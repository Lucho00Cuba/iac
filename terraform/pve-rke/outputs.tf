// OUTPUT'S

output "ips" {
    value = "${proxmox_lxc.k0s[*].network[*].ip}"
    description = "Nodes Ips"
}

output "ids" {
    value = "${proxmox_lxc.k0s[*].id}"
    description = "Nodes Ids"
}