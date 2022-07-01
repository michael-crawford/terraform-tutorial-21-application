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

variable "domain" {
  description = "Domain Name"
  type        = string
  default     = "x.mcrawford.mjcconsulting.com"
}
