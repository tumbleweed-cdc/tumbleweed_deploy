resource "aws_ecs_service" "kafka_controller_1" {
  name            = "kafka-controller-1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_1.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_controller_1.arn
  }
}

resource "aws_ecs_service" "kafka_controller_2" {
  name            = "kafka-controller-2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_2.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_controller_2.arn
  }
}

resource "aws_ecs_service" "kafka_controller_3" {
  name            = "kafka-controller-3"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_3.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_controller_3.arn
  }
}

resource "aws_ecs_service" "kafka_broker_1" {
  name            = "kafka-broker-1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_1.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_broker_1.arn
  }
}

resource "aws_ecs_service" "kafka_broker_2" {
  name            = "kafka-broker-2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_2.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_broker_2.arn
  }
}

resource "aws_ecs_service" "kafka_broker_3" {
  name            = "kafka-broker-3"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_3.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_broker_3.arn
  }
}

resource "aws_ecs_service" "apicurio_registry" {
  name            = "apicurio-registry"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.apicurio_registry.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.apicurio.arn
  }
}

resource "aws_ecs_service" "connect" {
  name            = "connect-debezium"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.connect.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.connect.arn
  }
}

resource "aws_ecs_service" "tumbleweed_user_config_db" {
  name            = "tumbleweed-user-config-db"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tumbleweed_user_config_db.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.private_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.tumbleweed_config_db.arn
  }
}

resource "aws_ecs_service" "tumbleweed_app" {
  name            = "tumbleweed-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tumbleweed_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.public_subnet_id]
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.tumbleweed_app.arn
  }
}
