# Creating a code storage bucket
resource "google_storage_bucket" "bucket" {
  name                        = var.bucket_name
  location                    = var.location
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = var.uniform_bucket_level_access
}

resource "google_storage_bucket_object" "objects" {
  count  = length(var.objects)
  name   = var.objects[count.index].name
  bucket = google_storage_bucket.bucket.name
  source = var.objects[count.index].source
}
