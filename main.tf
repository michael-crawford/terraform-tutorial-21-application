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

################################################################################
# Security Groups
################################################################################

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

module "application_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "${var.environment}-${var.application}-InstanceSecurityGroup"
  description = "${var.environment}-${var.application}-InstanceSecurityGroup"

  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules       = ["ssh-tcp", "http-80-tcp", "http-8080-tcp"]
  ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]

  egress_rules        = ["all-all"]

  tags = local.common_tags
}

module "application_balancer_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "${var.environment}-${var.application}-BalancerSecurityGroup"
  description = "${var.environment}-${var.application}-BalancerSecurityGroup"

  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]

  tags = local.common_tags

  ingress_with_cidr_blocks = [
    {
      from_port   = 81
      to_port     = 81
      protocol    = 6
      description = "Allow Port 81 from internet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

data "aws_route53_zone" "domain" {
  name         = var.domain
}

resource "aws_key_pair" "administrator" {
  key_name   = var.instance_keypair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU9mdeb+HCafxD0dwedSxZDJyzTrLz/lAGS8gTYrP4qYLmIWziKGv4d3Bd5JYk6sWL5yfVCm1NUdkzczcbygM1Q4HrQ6Xmj++gOyGyGPynNy3Unn9lWk5OVdG3zIDT/Qet84Tsxyjpmh/4hhL8ZM0SaDPF1S6ra825Q0vYbLOH4u8/88gruzNrjrU00RCQ/YQtIycqlOc/LiWQgFN7h6vrPU3V9fWtQxulh+SE+Yw+gkFjR61mmtjiZCi9hL2C29pwGcBOiXBJXGIwcxp2w/r5FiBXuqqT4cbfHO8olcwQ5m2kSUMbwcSOrJ3V0ciVbVaRsTfxVGmLsJCu4pAiZJviITPca2uBGjBHx4pW9syZMGRTZR+s8YwbGBMv2nNdmCc+MI0yElHuzWcoYHC7FiUm+MNrHDgfKOdToptPW+oKNTISjE4e03FaHn83bzHKGPqzDmv4lhI8WhS3t835ypwmCcpLn6DBUCLStY9578s3yjw5XXa5QVqcw1t2hnNPkRFQhmLSn6Qc6vwbkUprnSR6i0nnnbyRl+7v04N2ei2EhaykE8pXED9FUVLqyROiG6UBRPgcqC51oM3I5LmphfYYXL5MqClbfK06F9l2+rej0EEzlSv8Fm4SLRVD44vJkMiDObmDnQXiJQrILc2gZlSxfFF2JT4b5qAOTDnLahPjxw== administrator@mjcconsulting.com"
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  name                   = "${var.environment}-Bastion-Instance"

  instance_count         = 1
  ami                    = data.aws_ami.amzn2.id
  instance_type          = var.instance_type
  key_name               = var.instance_keypair
  monitoring             = true

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[0]

  vpc_security_group_ids = [module.bastion_instance_security_group.security_group_id]

  tags = local.common_tags
}

