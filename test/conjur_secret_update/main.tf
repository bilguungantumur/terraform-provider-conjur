terraform {
  required_providers {
    conjur = {
      # We are building the plugin in this path which probably needs to be changed
      #  go build -o ~/.terraform.d/plugins/terraform.example.com/cyberark/conjur/0.6.6/darwin_amd64/terraform-provider-conjur main.go
      source  = "terraform.example.com/cyberark/conjur"
      version = "~> 0"
    }
  }
}

provider "conjur" {
  alias         = "read"
  appliance_url = "https://conjur-nonprod-follower.cisco.com"
}

provider "conjur" {
  alias         = "write"
  appliance_url = "https://conjur-nonprod-write.cisco.com"
}

resource "random_password" "token" {
  length  = 64
  special = false
}

data "conjur_secret_update" "passwordupdate" {
  provider     = conjur.write
  name         = "it/hc_service_account/bill_test_2/bill_another_secret"
  update_value = random_password.token.result
}

data "conjur_secret" "password" {
  depends_on   = [data.conjur_secret_update.passwordupdate]
  provider     = conjur.read
  name         = "it/hc_service_account/bill_test_2/bill_another_secret"
}

output "pass-to-output" {
  value     = data.conjur_secret.password.value
  sensitive = true
}

resource "local_file" "pass-to-file" {
  content         = data.conjur_secret.password.value
  filename        = "${path.module}/../pass"
  file_permission = "0664"
}
