# Getting project information
data "google_project" "project" {}

# VPC Module
module "vpc" {
  source                  = "./modules/vpc"
  vpc_name                = "vpc"
  auto_create_subnetworks = false
  vpc_connectors = [
    {
      name          = "serverless-vpc-connector"
      ip_cidr_range = "10.8.0.0/28"
      min_instances = 2
      max_instances = 5
      machine_type  = "f1-micro"
    }
  ]
  subnets = [
    {
      name          = "subnet"
      region        = var.location
      ip_cidr_range = "10.0.1.0/24"
    }
  ]
}

module "instance_firewalls" {
  source = "./modules/firewall"
  vpc_id = module.vpc.vpc_id
  firewalls = [
    {
      name               = "vpc-connector-firewall"
      direction          = "INGRESS"
      source_ranges      = ["10.8.0.0/28"]
      destination_ranges = ["${module.instance.network_ip}/32"]
      allow_list = [
        {
          protocol = "tcp"
          ports    = ["80"]
        }
      ]
    },
    {
      name               = "allow-ssh"
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = []
      allow_list = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  ]
  depends_on = [module.vpc, module.instance]
}

# Code Storage Bucket
module "gcs" {
  source                      = "./modules/gcs"
  bucket_name                 = "encoded-alpha-code-bucket"
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true
  objects = [
    {
      name   = "encoded-alpha-code-object"
      source = "./files/code.zip"
    }
  ]
}

# Virtual Machine
module "instance" {
  source       = "./modules/compute"
  name         = "vm-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  network_interfaces = [
    {
      access_configs = []
      network        = module.vpc.vpc_id
      subnetwork     = module.vpc.subnets[0].id
    }
  ]
  metadata = {
    startup-script = <<-EOT
#! /bin/bash
echo 'Hello World !' > index.html
sudo python3 -m http.server 80
    EOT
  }
  image                     = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
  deletion_protection       = false
  allow_stopping_for_update = true
}

# Service Account
data "google_compute_default_service_account" "default_sa" {}

resource "google_project_iam_member" "default_sa_permissions" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/storage.objectViewer",
    "roles/artifactregistry.writer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_compute_default_service_account.default_sa.email}"
}

# Cloud Run Function
module "function" {
  source               = "./modules/cloud-run-function"
  function_name        = "serverless-vpc-handler"
  function_description = "serverless-vpc-handler"
  location             = var.location
  handler              = "handler"
  runtime              = "python312"
  build_env_variables = {
    VM_PRIVATE_IP = module.instance.network_ip
  }
  storage_source_bucket          = module.gcs.bucket
  storage_source_bucket_object   = module.gcs.objects[0].name
  max_instance_count             = 3
  min_instance_count             = 1
  vpc_connector                  = module.vpc.vpc_connectors[0].name
  available_memory               = "256M"
  timeout_seconds                = 60
  all_traffic_on_latest_revision = true
  ingress_settings               = "ALLOW_ALL"
  depends_on                     = [google_project_iam_member.default_sa_permissions]
}
