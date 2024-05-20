variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "api_management_name" {
  type = string
}

variable "api_management_sku" {
  type    = string
  default = "Developer_1"
}

variable "network_type" {
  type    = string
  default = "Internal"
}

variable "subnet_id" {
  type = string
}

variable "container_app_url" {
  type = string
}