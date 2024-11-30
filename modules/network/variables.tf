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

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
  default     = "vnet-dcai-prod-uaen-001"
}

variable "vnet_address_space" {
  type        = string
  description = "Address space for the Virtual Network"
  default     = "172.16.173.0/24"
}

variable "subnets" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
  description = "Map of subnets to create"
  default = {
    db = {	
      name           = "snet-dcai-prod-db-uaen-001" 
      address_prefix = "172.16.173.16/28"
    }
    redis = {
      name           = "snet-dcai-prod-cache-uaen-001"
      address_prefix = "172.16.173.32/28"
    }
    blob_storage = {
      name           = "snet-dcai-prod-storage-uaen-001"
      address_prefix = "172.16.173.48/28"
    }
    appservice = {
      name           = "snet-dcai-prod-app-uaen-001"
      address_prefix = "172.16.173.64/28"
    }
    private_endpoint = {
      name           = "snet-dcai-prod-pep-uaen-001"
      address_prefix = "172.16.173.80/28"
    }
    application_gateway = {
      name              = "snet-dcai-prod-app-gate-uaen-001"
      address_prefix    = "172.16.173.96/28"
    }
  }
}


