
variable "location" {}
variable "function_name" {}
variable "function_description" {}
variable "runtime" {}
variable "handler" {}
variable "build_env_variables" {
  type = map(string)
}
variable "ingress_settings" {}
variable "all_traffic_on_latest_revision" {}
variable "max_instance_count" {}
variable "min_instance_count" {}
variable "available_memory" {}
variable "timeout_seconds" {}
variable "vpc_connector" {}

variable "storage_source_bucket" {}
variable "storage_source_bucket_object" {}
