 terraform {
    backend "gcs" {
      bucket = "tfstate-bucket-gcp"
      prefix = "terraform/state-file" 
    }
  }