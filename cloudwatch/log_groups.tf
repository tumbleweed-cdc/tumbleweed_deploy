resource "aws_cloudwatch_log_group" "kafka_controller_1_log_group" {
  name = "kafka-controller-1-logs"
}

resource "aws_cloudwatch_log_group" "kafka_controller_2_log_group" {
  name = "kafka-controller-2-logs"
}

resource "aws_cloudwatch_log_group" "kafka_controller_3_log_group" {
  name = "kafka-controller-3-logs"
}

resource "aws_cloudwatch_log_group" "kafka_broker_1_log_group" {
  name = "kafka-broker-1-logs"
}

resource "aws_cloudwatch_log_group" "kafka_broker_2_log_group" {
  name = "kafka-broker-2-logs"
}

resource "aws_cloudwatch_log_group" "kafka_broker_3_log_group" {
  name = "kafka-broker-3-logs"
}

resource "aws_cloudwatch_log_group" "apicurio_registry_log_group" {
  name = "apicurio-registry-logs"
}

resource "aws_cloudwatch_log_group" "connect_log_group" {
  name = "connect-debezium-logs"
}

resource "aws_cloudwatch_log_group" "tumbleweed_user_config_db_log_group" {
  name = "tumbleweed-user-config-db-logs"
}

resource "aws_cloudwatch_log_group" "tumbleweed_app_log_group" {
  name = "tumbleweed-app-logs"
}