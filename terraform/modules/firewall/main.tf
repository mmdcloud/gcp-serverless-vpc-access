# Creating a Firewall
resource "google_compute_firewall" "firewall" {
  count              = length(var.firewalls)
  network            = var.vpc_id
  name               = var.firewalls[count.index].name
  direction          = var.firewalls[count.index].direction
  source_ranges      = var.firewalls[count.index].source_ranges
  destination_ranges = var.firewalls[count.index].destination_ranges
  dynamic "allow" {
    for_each = var.firewalls[count.index].allow_list
    content {
      protocol = allow.value["protocol"]
      ports    = allow.value["ports"]
    }
  }
}