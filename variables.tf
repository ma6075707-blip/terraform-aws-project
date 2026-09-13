variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_profile" {
  type    = string
  default = "myprofile"
}

variable "project_name" {
  type    = string
  default = "two-vpc-project"
}

variable "vpc1_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc2_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "newkey"
}

variable "azs" {
  type = list(string)

  default = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}