variable "vpc_id" {
  type = string
}
variable "firewalls" {
  type = list(object({
    name               = string
    direction          = string
    source_ranges      = set(string)
    destination_ranges = set(string)
    allow_list = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}