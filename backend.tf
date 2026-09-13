terraform {
  backend "s3" {
    bucket = "terraform-state-user01-036253061913"
    key    = "task3/terraform.tfstate"
    region = "eu-west-1"
  }
}