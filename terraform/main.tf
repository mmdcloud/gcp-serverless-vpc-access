# Creating a VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc"
  auto_create_subnetworks = false
}

# Creating a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.location
  network       = google_compute_network.vpc.id
}

# Creating a code storage bucket
resource "google_storage_bucket" "bucket" {
  name                        = "nodal-talon-code-bucket"
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "bucket_object" {
  name   = "nodal-talon-code-object"
  bucket = google_storage_bucket.bucket.name
  source = "./files/code.zip"
}


# Creating a Firewall
resource "google_compute_firewall" "vpc_connector_firewall" {
  name               = "vpc-connector-firewall"
  direction          = "INGRESS"
  network            = google_compute_network.vpc.id
  source_ranges      = ["10.8.0.0/28"]
  destination_ranges = ["${google_compute_instance.instance.network_interface[0].network_ip}/32"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Creating storage

# Creating a Virtual Machine
resource "google_compute_instance" "instance" {
  name         = "vm-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
  }
  metadata = {
    startup-script = <<-EOT
#! /bin/bash
echo 'Hello World !' > index.html
sudo python3 -m http.server 80
    EOT
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
    }
  }

  deletion_protection       = false
  allow_stopping_for_update = true
}

# Creating a Serverless VPC connector
resource "google_vpc_access_connector" "connector" {
  name          = "serverless-vpc-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
  min_instances = 2
  max_instances = 5
  machine_type  = "f1-micro"
}

resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.serverless_vpc_handler.project
  location       = google_cloudfunctions2_function.serverless_vpc_handler.location
  cloud_function = google_cloudfunctions2_function.serverless_vpc_handler.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloud_run_service_iam_member" "cloud_run_invoker" {
  project  = google_cloudfunctions2_function.serverless_vpc_handler.project
  location = google_cloudfunctions2_function.serverless_vpc_handler.location
  service  = google_cloudfunctions2_function.serverless_vpc_handler.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Creating a Cloud Run Function

resource "google_cloudfunctions2_function" "serverless_vpc_handler" {
  name        = "serverless-vpc-handler"
  location    = var.location
  description = "serverless-vpc-handler"
  build_config {
    entry_point = "handler"
    runtime     = "python312"
    environment_variables = {
      VM_PRIVATE_IP = google_compute_instance.instance.network_interface[0].network_ip
    }
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.bucket_object.name
      }
    }
  }
  service_config {
    max_instance_count = 3
    min_instance_count = 1
    vpc_connector      = google_vpc_access_connector.connector.name
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      VM_PRIVATE_IP = google_compute_instance.instance.network_interface[0].network_ip
    }
    all_traffic_on_latest_revision = true
    ingress_settings               = "ALLOW_ALL"
  }
}
