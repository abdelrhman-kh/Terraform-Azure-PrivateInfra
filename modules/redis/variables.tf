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

variable "redis_name" {
  type        = string
  description = "Name of the Redis cache"
  default     = "cache-dcai-prod-uaen-001"
}

variable "redis_pep_name" {
  type        = string
  description = "Private Endpoint for Redis"
  default     = "pep-dcai-prod-cache-uaen-001"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet for the Private Endpoint"
}

# modules/redis/variables.tf or wherever your variables are declared in the redis module
variable "vnet_id" {
  description = "The ID of the Virtual Network"
  type        = string
}

