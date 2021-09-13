terraform {
  backend "gcs" {
    bucket = "BUCKET_ID" #bkt-b-tfstate-d054
    prefix = "environments/prod"
  }
}
