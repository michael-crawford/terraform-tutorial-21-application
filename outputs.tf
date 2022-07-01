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

output "domain_zoneid" {
  description = "The Hosted Zone id of the desired Hosted Zone"
  value       = data.aws_route53_zone.domain.zone_id
}

output "domain_name" {
  description = " The Hosted Zone name of the desired Hosted Zone."
  value       = data.aws_route53_zone.domain.name
}

output "bastion_ids" {
  description = "List of IDs of instances"
  value       = module.bastion.id
}

output "bastion_public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = module.bastion.public_ip
}
