# Input variable definitions

variable "access_key" {}
variable "secret_key" {}
	
variable "region" {
    type = string
    description = "aws region where the VM will be provisioned"
    default = "us-west-2"
}
	
variable "instance_ssh_public_key" {}

variable "subnet_id" {}

variable "vpc_security_group_ids" {}

