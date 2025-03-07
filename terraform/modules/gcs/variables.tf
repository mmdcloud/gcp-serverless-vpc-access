variable "bucket_name" {}
variable "location" {}
variable "force_destroy" {}
variable "uniform_bucket_level_access" {}

variable "objects" {
  type = list(object({
    name   = string
    source = string
  }))
}
