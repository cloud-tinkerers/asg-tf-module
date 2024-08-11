locals {
  current_account_id = data.aws_caller_identity.current.id
  subnet_id          = data.aws_subnet.subnet.id

  default_tags = {
    Terraform   = "true"
    Environment = "${var.env}"
    Client      = "${var.client}"
    Application = "${var.app}"
  }
}

data "aws_caller_identity" "current" {}

// Find the subnet ID for eu-west-1a public
data "aws_subnet" "subnet" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "availability-zone"
    values = [var.azs[0]]
  }

  filter {
    name   = "tag:Tier"
    values = ["public"]
  }
}