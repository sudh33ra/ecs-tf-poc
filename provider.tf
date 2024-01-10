# AWS configuration
provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                 = "pg"
  region                  = "${var.aws_region}"
}
