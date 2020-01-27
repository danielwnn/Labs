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

variable "hostname" {
  description = "VM hostname"
  default     = "vmtflab"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "vmadmin"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
}
