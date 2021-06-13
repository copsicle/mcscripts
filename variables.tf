variable "prefix" {
  type = string
  default = "mc"
  description = "The prefix which should be used for all resources"
}

variable "region" {
  type = string
  default = "germanywestcentral"
  description = "The Azure Region in which all resources in this example should be created, Frankfurt is default."
}

variable "vm" {
  type = string
  default = "Standard_B1ms"
  description = "The type of VM instance which should be used (B1s is free-tier, 1 vcpu, 1gb ram)"
}

variable "username" {
  type = string
  default = "mc"
  description = "The user name in the VM"
}

variable "key" {
  type = string
  default = "~/.ssh/id_rsa.pub"
  description = "Path to your public SSH key"
}

variable "mcport" {
  type = string
  default = "25565"
  description = "Port for the minecraft server"
}
variable "disktype" {
  type = string
  default = "Premium_LRS"
  description = "Type of disk to use, premium SSD has free tier"
}

variable "disksize" {
  type = number
  default = 64
  description = "Size of OS disk, 64GB premium is free tier"
}