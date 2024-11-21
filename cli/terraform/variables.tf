variable "region" {
  description = "AWS region"
  type        = string
}

variable "profile" {
  description = "AWS profile to use"
  default     = "default"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the ECS security group"
  type        = list(string)
}

variable "iam_arn" {
  description = "iam_arn"
  type        = string
}