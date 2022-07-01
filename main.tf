locals {
  environment = var.environment
  company = var.company
  project = var.project

  common_tags = {
    Environment = local.environment
    Company     = local.company
    Project     = local.project
  }

  asg_tags = [
    {
      key                 = "Project"
      value               = var.project
      propagate_at_launch = true
    }
  ]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_pet" "this" {
  length = 2
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "mjcconsulting"
    workspaces = {
      name = "MJCConsulting-MCrawford-Sandbox-terraform-tutorial-21-vpc"
    }
  }
}

/*
1. Security Group
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
    ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]

2. Bastion Host
    subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[0]

3. ALB
    subnets = data.terraform_remote_state.vpc.outputs.public_subnets

4. ASG
    vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets 

5. Null Resource
    command = "echo VPC created on `date` and VPC ID: ${data.terraform_remote_state.vpc.outputs.vpc_id} >> creation-time-vpc-id.txt"
*/

module "bastion_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "${var.environment}-Bastion-InstanceSecurityGroup"
  description = "${var.environment}-Bastion-InstanceSecurityGroup"

  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules        = ["all-all"]

  tags = local.common_tags
}
