variable "vpc_name" {}
variable "auto_create_subnetworks" {}

variable "subnets" {
  type = list(object({
    name         = string
    ip_cidr_range = string
    region        = string    
  }))
}

variable "vpc_connectors" {
  type = list(object({
    name          = string
    ip_cidr_range = string
    min_instances = number
    max_instances = number
    machine_type  = string
  }))
}