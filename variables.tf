variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "Production"
}

variable "company" {
  description = "Company Name"
  type        = string
  default     = "MJCConsulting"
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "Tutorial-21"
}

variable "application" {
  description = "Application Name"
  type        = string
  default     = "App1"
}

variable "domain" {
  description = "Domain Name"
  type        = string
  default     = "x.mcrawford.mjcconsulting.com"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3a.nano"
}

variable "instance_keypair" {
  description = "AWS EC2 Key Pair"
  type        = string
  default     = "administrator"
}

variable "instance_count" {
  description = "AWS EC2 Instance Count"
  type        = number
  default     = 1
}
