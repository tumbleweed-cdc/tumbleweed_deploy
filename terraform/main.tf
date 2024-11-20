module networking {
  source = "./networking"
}

module "security" {
  source = "./security"
  vpc_id = module.networking.vpc_id
  allowed_ips = var.allowed_ips
}

module "cloudwatch" {
  source = "./cloudwatch"
}

module "ecs" {
  source = "./ecs"
  vpc_id = module.networking.vpc_id
  aws_region = var.region
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_security_group_id = module.security.ecs_security_group_id
  public_subnet_id = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  kafka_controller_1_log_group_name = module.cloudwatch.kafka_controller_1_log_group_name
  kafka_controller_2_log_group_name = module.cloudwatch.kafka_controller_2_log_group_name
  kafka_controller_3_log_group_name = module.cloudwatch.kafka_controller_3_log_group_name
  kafka_broker_1_log_group_name = module.cloudwatch.kafka_broker_1_log_group_name
  kafka_broker_2_log_group_name = module.cloudwatch.kafka_broker_2_log_group_name
  kafka_broker_3_log_group_name = module.cloudwatch.kafka_broker_3_log_group_name
  apicurio_registry_log_group_name = module.cloudwatch.apicurio_registry_log_group_name
  connect_log_group_name = module.cloudwatch.connect_log_group_name
  tumbleweed_user_config_db_log_group_name = module.cloudwatch.tumbleweed_user_config_db_log_group_name
  tumbleweed_app_log_group_name = module.cloudwatch.tumbleweed_app_log_group_name
}

module "iam" {
  source = "./iam"
  iam_arn = var.iam_arn
}

