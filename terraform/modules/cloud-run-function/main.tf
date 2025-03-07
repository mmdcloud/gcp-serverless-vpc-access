resource "google_cloudfunctions2_function_iam_member" "invoker" {
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloud_run_service_iam_member" "cloud_run_invoker" {
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Creating a Cloud Run Function
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.location
  description = var.function_description
  build_config {
    runtime               = var.runtime
    entry_point           = var.handler
    environment_variables = var.build_env_variables
    source {
      storage_source {
        bucket = var.storage_source_bucket
        object = var.storage_source_bucket_object
      }
    }
  }
  service_config {
    vpc_connector                  = var.vpc_connector
    # vpc_connector_egress_settings  = var.vpc_connector_egress_settings
    max_instance_count             = var.max_instance_count
    min_instance_count             = var.min_instance_count
    available_memory               = var.available_memory
    timeout_seconds                = var.timeout_seconds
    environment_variables          = var.build_env_variables
    ingress_settings               = var.ingress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    # service_account_email          = var.function_app_service_account_email
  }
}



# resource "google_cloudfunctions2_function" "serverless_vpc_handler" {
#   name        = "serverless-vpc-handler"
#   location    = var.location
#   description = "serverless-vpc-handler"
#   build_config {
#     entry_point = "handler"
#     runtime     = "python312"
#     environment_variables = {
#       VM_PRIVATE_IP = google_compute_instance.instance.network_interface[0].network_ip
#     }
#     source {
#       storage_source {
#         bucket = google_storage_bucket.bucket.name
#         object = google_storage_bucket_object.bucket_object.name
#       }
#     }
#   }
#   service_config {
#     max_instance_count = 3
#     min_instance_count = 1
#     vpc_connector      = google_vpc_access_connector.connector.name
#     available_memory   = "256M"
#     timeout_seconds    = 60
#     environment_variables = {
#       VM_PRIVATE_IP = google_compute_instance.instance.network_interface[0].network_ip
#     }
#     all_traffic_on_latest_revision = true
#     ingress_settings               = "ALLOW_ALL"
#   }
# }