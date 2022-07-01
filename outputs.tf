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

/*
output "private_sg_group_id" {
  description = "The ID of the security group"
  value       = module.private_sg.security_group_id
}

output "private_sg_group_vpc_id" {
  description = "The VPC ID"
  value       = module.private_sg.security_group_vpc_id
}

output "private_sg_group_name" {
  description = "The name of the security group"
  value       = module.private_sg.security_group_name
}
*/
