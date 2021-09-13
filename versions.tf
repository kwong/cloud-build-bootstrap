terraform {
  required_version = ">=0.13.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50"
    }

    google-beta = {
      google = {
        source  = "hashicorp/google"
        version = ">= 3.50"
      }
    }
  }
}