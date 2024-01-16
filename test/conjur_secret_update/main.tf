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

resource "random_password" "token" {
  length  = 64
  special = false
}

data "conjur_secret_update" "passwordupdate" {
  name = "it/hc_service_account/bill_test_2/bill_another_secret"
  update_value = random_password.token.result
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
