terraform {
  required_providers {
    conjur = {
      source  = "terraform.example.com/cyberark/conjur"
      version = "~> 0"
    }
  }
}

provider "conjur" {
  # All variables for this tests are passed in through env vars
}

data "conjur_secret_update" "passwordupdate" {
  name = "it/hc_service_account/bill/bill_policy1/sub1/password"
  update_value = "test12345"
}

output "pass-to-output" {
  value = data.conjur_secret_update.passwordupdate.value
  sensitive = true
}

resource "local_file" "pass-to-file" {
  content = data.conjur_secret_update.passwordupdate.value
  filename = "${path.module}/../pass"
  file_permission = "0664"
}
