variable "resource_group_name" {
  description = "The name of the resource group"
  default = "rg-terraform-lab"
}

variable "location" {
  description = "The location/region of the resources"
  default     = "westus"
}

variable "tags" {
    description = "The resource tags"
    default     = {
        company         = "Appriss Retail"
        environment     = "training"
    }
}

variable "storage_account_name" {
  description = "storage account for terraform state file"
}

variable "storage_account_name" {
  description = "storage account for terraform state file"
}

variable "container_name" {
  description = "storage account container name for terraform state file"
}

variable "state_file_name" {
  description = "terraform state file name"
}

variable "hostname" {
  description = "VM hostname"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
}
