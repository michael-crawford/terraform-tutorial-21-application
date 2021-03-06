variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "company" {
  description = "Company Name"
  type        = string
  default     = "MJCConsulting"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "Production"
}

variable "application" {
  description = "Application Name"
  type        = string
  default     = "App1"
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "Tutorial-21"
}

variable "domain" {
  description = "Domain Name"
  type        = string
  default     = "x.mcrawford.mjcconsulting.com"
}

variable "notification_email" {
  description = "Email Address to send Notifications"
  type        = string
  default     = "terraform@mjcconsulting.com"
}

variable "hostname_prefix" {
  description = "Hostname Prefix"
  type        = string
  default     = "mjcue2papp1"
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
