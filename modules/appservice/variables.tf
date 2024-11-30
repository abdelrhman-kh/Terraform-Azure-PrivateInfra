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

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan Name"
  default     = "asp-dcai-prod-uaen-001"
}

variable "app_service_name" {
  type        = string
  description = "App Service Name"
  default     = "web-dcai-prod-uaen-001"
}

variable "app_service_pep_name" {
  type        = string
  description = "Private Endpoint for App Service"
  default     = "pep-dcai-prod-web-uaen-001"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet for the Private Endpoint"
}

# variable "file_name" {
#   type        = string
#   description = "The name of the file to be uploaded to App Service"
#   default     = "myfile.txt"
# }


# Define a variable for the private_service_connection name
variable "private_service_connection_name" {
  type        = string
  description = "The name of the private_service_connection."
  default     = "appservice-pep-connection"
}

# Define a variable for the MySQL server name
variable "mysql_server_name" {
  type        = string
  description = "The name of the MySQL server."
}

# Define a variable for the Redis hostname
variable "redis_hostname" {
  type        = string
  description = "The hostname of the Redis cache."
}

# Define a variable for the Redis Primary Access Key
variable "redis_primary_access_key" {
  type        = string
  description = "The primary access key of the Redis cache."
}

variable "storage_account_key" {
  description = "Primary access key for the storage account."
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account."
  type        = string
}

variable "blob_container_name" {
  description = "Name of the blob container."
  type        = string
}

variable "mysql_server_admin_login" {
  description = "login of the Mysql Server."
  type        = string
}

variable "mysql_server_admin_password" {
  description = "Password of the Mysql Server."
  type        = string
}

variable "other_part" {
  default = "base64:"
}