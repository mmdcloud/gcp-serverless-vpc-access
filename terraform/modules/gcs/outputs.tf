output "bucket" {
    value = google_storage_bucket.bucket.name
}

output "objects" {
    value = google_storage_bucket_object.objects[*]
}