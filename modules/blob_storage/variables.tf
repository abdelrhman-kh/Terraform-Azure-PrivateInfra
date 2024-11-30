variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account."
  default     = "dcai0prod0"
}

variable "container_name" {
  type        = string
  description = "The name of the Blob Container."
  default     = "blob-dcai-prod-storage-uaen-001"
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
  description = "The subnet ID for the private endpoint."
  type        = string
}

variable "storage_account_pep_name" {
  type        = string
  description = "Private Endpoint for Redis"
  default     = "pep-dcai-prod-storage-uaen-001"
}