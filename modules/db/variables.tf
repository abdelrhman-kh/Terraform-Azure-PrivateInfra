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

variable "mysql_name" {
  type        = string
  description = "Name of the MySQL instance"
}

variable "mysql_pep_name" {
  type        = string
  description = "Private Endpoint for MySQL"
  default     = "pep-dcai-prod-mysql-uaen-001"
}

variable "admin_user" {
  type        = string
  description = "Database administrator username"
  default     = "adminuser"
}

variable "admin_password" {
  type        = string
  description = "Administrator password for MySQL Flexible Server"
  default     = "SuperSecretPassword123!"  # Example password with complexity
}


variable "subnet_id" {
  type        = string
  description = "The ID of the subnet for the Private Endpoint"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network"
}

variable "mysql_replica_name" {
  description = "The name of the MySQL replica server."
  type        = string
}
