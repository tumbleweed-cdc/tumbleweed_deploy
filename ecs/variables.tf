variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type = string
}

variable "aws_region" {
  description = "AWS region for ECS task definitions"
  type        = string
}

variable "execution_role_arn" {
  description = "Execution role ARN for ECS tasks"
  type        = string
}

variable "kafka_controller_1_log_group_name" {
  description = "CloudWatch Log group for Kafka controller 1"
  type        = string
}

variable "kafka_controller_2_log_group_name" {
  description = "CloudWatch Log group for Kafka controller 2"
  type        = string
}

variable "kafka_controller_3_log_group_name" {
  description = "CloudWatch Log group for Kafka controller 3"
  type        = string
}

variable "kafka_broker_1_log_group_name" {
  description = "CloudWatch Log group for Kafka broker 1"
  type        = string
}

variable "kafka_broker_2_log_group_name" {
  description = "CloudWatch log group name for Kafka broker 2"
  type        = string
}

variable "kafka_broker_3_log_group_name" {
  description = "CloudWatch log group name for Kafka broker 3"
  type        = string
}

variable "apicurio_registry_log_group_name" {
  description = "CloudWatch log group name for Apicurio Registry"
  type        = string
}

variable "connect_log_group_name" {
  description = "CloudWatch log group name for connect debezium"
  type        = string
}

variable "tumbleweed_user_config_db_log_group_name" {
  description = "CloudWatch log group name for Tumbleweed user config db"
  type        = string
}

variable "tumbleweed_app_log_group_name" {
  description = "CloudWatch log group name for tumbleweed app"
  type        = string
}

variable "ecs_security_group_id" {
  description = "value of the security group id"
  type        = string
}