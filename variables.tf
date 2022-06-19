variable "resource_group_name" {
  default = "week6-prod"
}
variable "resource_group_name_stage" {
  default = "week6-stage"
}

variable "dbname_prod" {
  default = "psqlservice"
}
variable "dbname_stage" {

  default = "psqlservice-stage"
}


# variable "resource_group_name" {
#   default = "test3"
# }
variable "virtual_network_name" {
  default = "week5Vent"

}

variable "location" {
  default = "australiaeast"
}
variable "application_port" {
  default = 8080
}

# output "vmss_public_ip_fqdn" {
#   value = azurerm_public_ip.publicIpLB.fqdn
# }
variable "secret" {
  default = "Alex310224993"
}
