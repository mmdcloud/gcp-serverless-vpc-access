output "vpc_id"{
    value = google_compute_network.vpc.id
}

output "subnets"{
    value = google_compute_subnetwork.subnets[*]
}

output "vpc_connectors"{
    value = google_vpc_access_connector.connector[*]
}