variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the ECS security group"
  type        = list(string)
}