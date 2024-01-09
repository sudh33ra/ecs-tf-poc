# where to save Terraform state file
terraform {
  backend "s3" {
    bucket = "myapp-terraform-state"
    key    = "ecs-dev/terraform.tfstate"
    region = "us-east-1"
  }
}
