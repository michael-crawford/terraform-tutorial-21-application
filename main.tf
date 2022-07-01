locals {
  company = var.company
  environment = var.environment
  application = var.application
  project = var.project
  domain = var.domain

  hostname_prefix = var.hostname_prefix // Calculate programatically using pattern: ccclllpaaacc00z

  application_load_balancer_name = "tf-multi-app-projects.${var.domain}"

  common_tags = {
    Company     = local.company
    Environment = local.environment
    Application = local.application
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

################################################################################
# Data
################################################################################

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "mjcconsulting"
    workspaces = {
      name = "MJCConsulting-MCrawford-Sandbox-terraform-tutorial-21-vpc"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
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
  name = var.domain
}

################################################################################
# Key Pairs
################################################################################

resource "aws_key_pair" "administrator" {
  key_name   = var.instance_keypair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU9mdeb+HCafxD0dwedSxZDJyzTrLz/lAGS8gTYrP4qYLmIWziKGv4d3Bd5JYk6sWL5yfVCm1NUdkzczcbygM1Q4HrQ6Xmj++gOyGyGPynNy3Unn9lWk5OVdG3zIDT/Qet84Tsxyjpmh/4hhL8ZM0SaDPF1S6ra825Q0vYbLOH4u8/88gruzNrjrU00RCQ/YQtIycqlOc/LiWQgFN7h6vrPU3V9fWtQxulh+SE+Yw+gkFjR61mmtjiZCi9hL2C29pwGcBOiXBJXGIwcxp2w/r5FiBXuqqT4cbfHO8olcwQ5m2kSUMbwcSOrJ3V0ciVbVaRsTfxVGmLsJCu4pAiZJviITPca2uBGjBHx4pW9syZMGRTZR+s8YwbGBMv2nNdmCc+MI0yElHuzWcoYHC7FiUm+MNrHDgfKOdToptPW+oKNTISjE4e03FaHn83bzHKGPqzDmv4lhI8WhS3t835ypwmCcpLn6DBUCLStY9578s3yjw5XXa5QVqcw1t2hnNPkRFQhmLSn6Qc6vwbkUprnSR6i0nnnbyRl+7v04N2ei2EhaykE8pXED9FUVLqyROiG6UBRPgcqC51oM3I5LmphfYYXL5MqClbfK06F9l2+rej0EEzlSv8Fm4SLRVD44vJkMiDObmDnQXiJQrILc2gZlSxfFF2JT4b5qAOTDnLahPjxw== administrator@mjcconsulting.com"
}

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

################################################################################
# Bastion Instances
################################################################################

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

  tags = merge(
    { "Hostname" = "${local.hostname_prefix}01a" }, // TODO: calculate instance number and zone code
    local.common_tags
  )
}

resource "aws_eip" "bastion_eip" {
  depends_on = [ module.bastion ]

  instance = module.bastion.id[0]
  vpc      = true

  tags = local.common_tags
}

################################################################################
# Certificates
################################################################################

module "acm_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  domain_name  = trimsuffix(data.aws_route53_zone.domain.name, ".")
  zone_id      = data.aws_route53_zone.domain.zone_id

  subject_alternative_names = [
    "*.${var.domain}"
  ]

  tags = local.common_tags
}

################################################################################
# Application Load Balancers
################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"

  name = "${var.environment}-${var.application}-ALB"

  load_balancer_type = "application"

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = data.terraform_remote_state.vpc.outputs.public_subnets

  security_groups = [module.application_balancer_security_group.security_group_id]

  target_groups = [
    {
      name_prefix          = "app1-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/app1/index.html"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
    }
  ]

  http_tcp_listeners = [
    {
      port          = 80
      protocol      = "HTTP"
      action_type   = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm_certificate.acm_certificate_arn
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      }
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority = 1
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        path_patterns = ["/*"]
      }]
    }
  ]

  tags = local.common_tags
}

resource "aws_route53_record" "apps_dns" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = local.application_load_balancer_name

  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

################################################################################
# Launch Templates
################################################################################

resource "aws_launch_template" "launch_template" {
  name = "${var.environment}-${var.application}-LaunchTemplate"
  description = "Launch Template for Application ${var.application}"

  image_id = data.aws_ami.amzn2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.application_instance_security_group.security_group_id]

  key_name = var.instance_keypair
  user_data = filebase64("${path.module}/scripts/app1-install.sh")
  ebs_optimized = true

  #default_version = 1
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
     }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-${var.application}-ASG"
    }
  }
}

################################################################################
# Auto-Scaling Group
################################################################################

resource "aws_autoscaling_group" "asg" {
  name = "${var.environment}-${var.application}-AutoScalingGroup"

  desired_capacity = 2
  max_size = 10
  min_size = 2

  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.private_subnets

  target_group_arns = module.alb.target_group_arns

  health_check_type = "EC2"

  launch_template {
    id = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = [ "desired_capacity" ]
  }

  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}

## TODO: Comment below from original code. This bug is a year old and may be fixed, so check this later
## - AWS Bug for SNS Topic: https://stackoverflow.com/questions/62694223/cloudwatch-alarm-pending-confirmation
## - Due to that create SNS Topic with unique name

resource "random_pet" "this" {
  length = 2
}

resource "aws_sns_topic" "asg_sns_topic" {
  name = "myasg-sns-topic-${random_pet.this.id}"
}

resource "aws_sns_topic_subscription" "asg_sns_topic_subscription" {
  topic_arn = aws_sns_topic.asg_sns_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_autoscaling_notification" "asg_notifications" {
  group_names = [aws_autoscaling_group.asg.id]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.asg_sns_topic.arn
}

resource "aws_autoscaling_policy" "cpu_autoscaling_policy" {
  name        = "${var.environment}-${var.application}-CPUAutoScalingPolicy"
  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = aws_autoscaling_group.asg.id

  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

resource "aws_autoscaling_policy" "requests_autoscaling_policy" {
  name        = "${var.environment}-${var.application}-RequestsAutoScalingPolicy"
  policy_type = "TargetTrackingScaling"

  autoscaling_group_name = aws_autoscaling_group.asg.id

  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label =  "${module.alb.lb_arn_suffix}/${module.alb.target_group_arn_suffixes[0]}"
    }
    target_value = 10.0
  }
}

resource "aws_autoscaling_schedule" "increase_autoscaling_schedule" {
  scheduled_action_name  = "${var.environment}-${var.application}-IncreaseScheduledAction"
  autoscaling_group_name = aws_autoscaling_group.asg.id

  desired_capacity       = 8
  min_size               = 2
  max_size               = 10

  start_time             = "2030-03-30T11:00:00Z" //UTC
  recurrence             = "00 09 * * *"
}

resource "aws_autoscaling_schedule" "decrease_autoscaling_schedule" {
  scheduled_action_name  = "${var.environment}-${var.application}-DecreaseScheduledAction"
  autoscaling_group_name = aws_autoscaling_group.asg.id

  desired_capacity       = 2
  min_size               = 2
  max_size               = 10

  start_time             = "2030-03-30T21:00:00Z" // UTC
  recurrence             = "00 21 * * *"
}
