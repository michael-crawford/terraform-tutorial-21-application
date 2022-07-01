################################################################################
# Public Hosted Zone Outputs
################################################################################

output "domain_zoneid" {
  description = "The Hosted Zone ID of the domain"
  value       = data.aws_route53_zone.domain.zone_id
}

output "domain_name" {
  description = " The Hosted Zone Name of the domain"
  value       = data.aws_route53_zone.domain.name
}

################################################################################
# Security Group Outputs
################################################################################

output "bastion_instance_security_group_id" {
  description = "The ID of the security group"
  value       = module.bastion_instance_security_group.security_group_id
}

output "bastion_instance_security_group_vpc_id" {
  description = "The VPC ID"
  value       = module.bastion_instance_security_group.security_group_vpc_id
}

output "bastion_instance_security_group_name" {
  description = "The name of the security group"
  value       = module.bastion_instance_security_group.security_group_name
}

output "application_instance_security_group_id" {
  description = "The ID of the security group"
  value       = module.application_instance_security_group.security_group_id
}

output "application_instance_security_group_vpc_id" {
  description = "The VPC ID"
  value       = module.application_instance_security_group.security_group_vpc_id
}

output "application_instance_security_group_name" {
  description = "The name of the security group"
  value       = module.application_instance_security_group.security_group_name
}

output "bastion_ids" {
  description = "List of IDs of instances"
  value       = module.bastion.id
}

output "bastion_public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = module.bastion.public_ip
}

################################################################################
# Application Load Balancer Outputs
################################################################################
# We don't need all of these, reduce to minimum

output "lb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.lb_id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.lb_dns_name
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = module.alb.lb_arn_suffix
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.alb.lb_zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created"
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created"
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created"
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created"
  value       = module.alb.https_listener_ids
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group"
  value       = module.alb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch"
  value       = module.alb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group"
  value       = module.alb.target_group_names
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs"
  value       = module.alb.target_group_attachments
}

################################################################################
# Launch Template Outputs
################################################################################

output "launch_template_id" {
  description = "Launch Template ID"
  value = aws_launch_template.launch_template.id
}

output "launch_template_latest_version" {
  description = "Launch Template Latest Version"
  value = aws_launch_template.launch_template.latest_version
}

################################################################################
# AutoScaling Group Outputs
################################################################################

output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value = aws_autoscaling_group.asg.id 
}

output "autoscaling_group_name" {
  description = "Autoscaling Group Name"
  value = aws_autoscaling_group.asg.name 
}

output "autoscaling_group_arn" {
  description = "Autoscaling Group ARN"
  value = aws_autoscaling_group.asg.arn 
}
