# Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "random" {

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "application-vpc"
  cidr = "10.0.0.0/16"
  azs            = ["${var.region}a"]
  public_subnets = ["10.0.101.0/24"]
  tags = {
    createdBy = "techm-cfs-task5-assignment"
  }
}

data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  my_ip = jsondecode(data.http.my_public_ip.body)
}

module "ec2_instances" {
  source  = "./modules/aws-ec2-webserver"
  access_key = {}
  secret_key = {}
  instance_ssh_public_key = {}
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
}


resource "aws_security_group" "vm_sg" {
  name        = "vm-security-group"
  description = "Allow incoming connections."
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip.ip}/32"]
  }

  # application
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
