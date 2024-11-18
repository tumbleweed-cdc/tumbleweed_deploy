variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS profile to use"
  default     = "default"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the ECS security group"
  type        = list(string)
}