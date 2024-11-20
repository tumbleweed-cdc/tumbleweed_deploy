output "kafka_controller_1_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_controller_1_log_group.name
}

output "kafka_controller_2_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_controller_2_log_group.name
}

output "kafka_controller_3_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_controller_3_log_group.name
}

output "kafka_broker_1_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_broker_1_log_group.name
}

output "kafka_broker_2_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_broker_2_log_group.name
}

output "kafka_broker_3_log_group_name" {
  value = aws_cloudwatch_log_group.kafka_broker_3_log_group.name
}

output "apicurio_registry_log_group_name" {
  value = aws_cloudwatch_log_group.apicurio_registry_log_group.name
}

output "connect_log_group_name" {
  value = aws_cloudwatch_log_group.connect_log_group.name
}

output "tumbleweed_user_config_db_log_group_name" {
  value = aws_cloudwatch_log_group.tumbleweed_user_config_db_log_group.name
}

output "tumbleweed_app_log_group_name" {
  value = aws_cloudwatch_log_group.tumbleweed_app_log_group.name
}
