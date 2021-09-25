config {
  module = true
  force = false
  disabled_by_default = false
}

# plugins downloaded to ~/.tflint.d/
plugin "google" {
    enabled = true
    version = "0.12.1"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}
