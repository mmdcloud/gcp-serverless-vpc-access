# Creating a VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
}

# Creating a subnet
resource "google_compute_subnetwork" "subnets" {
  count         = length(var.subnets)
  name          = var.subnets[count.index].name
  ip_cidr_range = var.subnets[count.index].ip_cidr_range
  region        = var.subnets[count.index].region
  network       = google_compute_network.vpc.id
}

# Creating a Firewall
resource "google_compute_firewall" "vpc_connector_firewall" {
  count              = length(var.firewalls)
  network            = google_compute_network.vpc.id
  name               = var.firewalls[count.index].name
  direction          = var.firewalls[count.index].direction
  source_ranges      = var.firewalls[count.index].source_ranges
  destination_ranges = var.firewalls[count.index].destination_ranges
  dynamic "allow" {
    for_each = var.firewalls[count.index].firewalls
    content {
      protocol = allow.value["protocol"]
      ports    = allow.value["ports"]
    }
  }
}

# Creating a Serverless VPC connector
resource "google_vpc_access_connector" "connector" {
  count         = length(var.vpc_connectors)
  name          = var.vpc_connectors[count.index].name
  ip_cidr_range = var.vpc_connectors[count.index].ip_cidr_range
  min_instances = var.vpc_connectors[count.index].min_instances
  max_instances = var.vpc_connectors[count.index].max_instances
  machine_type  = var.vpc_connectors[count.index].machine_type
  network       = google_compute_network.vpc.name
}
