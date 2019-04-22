provider "aws" {
#  access_key = "${var.aws_access_key}"
#  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

terraform {
 backend "s3" {
 encrypt = true
 bucket = "ecs-terraform-remote-state-us-west-2"
 region = "us-west-2"
 key = "terraform.tfstate"
 }
}

