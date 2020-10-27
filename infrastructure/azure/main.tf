locals {
  project = "fd-lb-vm"

  tags = {
    Environment = "Test"
  }
}

resource "random_pet" "fido" {}