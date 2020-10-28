locals {
  project = "snat-test"

  tags = {
    Environment = "Test"
  }
}

resource "random_pet" "fido" {}