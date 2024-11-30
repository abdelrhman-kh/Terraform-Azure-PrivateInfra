variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "resource_suffix" {
  description = "The unique suffix for appending to resource names"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
  default     = "rg-network-dcai-prod-uaen-001"
}

variable "location" {
  type        = string
  description = "Location where resources will be created"
  default     = "uaenorth"
}

variable "subnet_id" {
  description = "Subnet ID where the Application Gateway will be deployed"
  type        = string
}

variable "sku_name" {
  description = "SKU name for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity of the Application Gateway"
  type        = number
  default     = 2
}

variable "ssl_cert_path" {
  description = "The file path to the SSL certificate in .pfx format"
  type        = string
}

variable "ssl_cert_password" {
  description = "The password for the SSL certificate"
  type        = string
  sensitive   = true
}

variable "appservice_private_ip" {
  description = "Private IP address for the App Service to be used in the Application Gateway backend"
  type        = string
}

variable "hostname_backend_setting" {
  description = "hostname  for the App Service to be used in the Application Gateway backend setting"
  type        = string
}

