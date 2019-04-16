provider "aws" {
#  access_key = "${var.aws_access_key}"
#  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

terraform {
 backend "s3" {
 encrypt = true
 bucket = "ECS-terraform-remote-state-${var.region}"
 region = ${var.region}
 key = "terraform.tfstate"
 }
}

