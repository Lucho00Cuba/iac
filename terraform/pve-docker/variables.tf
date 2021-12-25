# VARS

variable "pm_api_url" {
    type = string
    description = "EndPoint Proxmox"
}

variable "pm_password" {
    type = string
    default = "Password Proxmox"
}

variable "pm_user" {
    type = string
    description = "User Proxmox"
}    

variable "target_node" {
    type = string
    description = "Node"
}

variable "hostname" {
    type = string
    description = "Hostname LXC"
}

variable "ostemplate" {
    type = string
    description = "OS Template"
}

variable "password" {
    type = string
    description = "Password"
}

variable "storage" {
    type = string
    description = "Volume"
}

variable "size" {
    type = string
    description = "Size Volume"
}
