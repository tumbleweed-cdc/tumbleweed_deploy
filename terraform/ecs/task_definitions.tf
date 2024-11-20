resource "aws_ecs_task_definition" "kafka_controller_1" {
  family                   = "kafka-controller-1-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-1"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_controller_1_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "1" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        { name  = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "KAFKA_LISTENERS", value = "CONTROLLER://:9093" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "kafka_controller_2" {
  family                   = "kafka-controller-2-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-2"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_controller_2_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "2" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        { name  = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "KAFKA_LISTENERS", value = "CONTROLLER://:9093" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "kafka_controller_3" {
  family                   = "kafka-controller-3-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-3"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_controller_3_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "3" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        { name  = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "KAFKA_LISTENERS", value = "CONTROLLER://:9093" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "kafka_broker_1" {
  family                   = "kafka-broker-1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "kafka-broker-1"
      image     = "apache/kafka:3.9.0"
      essential = true
      pportMappings = [
        {
          containerPort = 9092
          protocol      = "tcp"
        },
        {
          containerPort = 19092
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_broker_1_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "4" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-1.kafka.local:19092,PLAINTEXT_HOST://localhost:29092" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "kafka_broker_2" {
  family                   = "kafka-broker-2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name = "kafka-broker-2"
      image = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9092
          protocol      = "tcp"
        },
        {
          containerPort = 19092
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_broker_2_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "5" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-2.kafka.local:19092,PLAINTEXT_HOST://localhost:39092" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" },
      ]
    }])
}

resource "aws_ecs_task_definition" "kafka_broker_3" {
  family                   = "kafka-broker-3"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

    container_definitions = jsonencode([
    {
      name = "kafka-broker-3"
      image = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9092
          protocol      = "tcp"
        },
        {
          containerPort = 19092
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.kafka_broker_3_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "6" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1.kafka.local:9093,2@controller-2.kafka.local:9093,3@controller-3.kafka.local:9093" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-3.kafka.local:19092,PLAINTEXT_HOST://localhost:49092" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "CLUSTER_ID", value = "4L6g3nShT-eMCtK--X86sw" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS", value = "0" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR", value = "1" },
        { name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR", value = "3" },
        { name = "KAFKA_LOG_DIRS", value = "/tmp/kraft-combined-logs" },
      ]
    }])
}

resource "aws_ecs_task_definition" "apicurio_registry" {
  family                   = "apicurio-registry-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "apicurio-registry"
      image = "apicurio/apicurio-registry:3.0.3"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.apicurio_registry_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "connect" {
  family                   = "connect-debezium"
  network_mode             = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn      = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "connect-debezium"
      image     = "debezium/connect:3.0.0.Final"
      essential = true
      portMappings = [
        { 
          containerPort = 8083
          protocol      = "tcp"
        }
      ]
      environment = [
        { name  = "BOOTSTRAP_SERVERS", value = "kafka-1.kafka.local:19092,kafka-2.kafka.local:19092,kafka-3.kafka.local:19092"},
        { name = "GROUP_ID", value = "1" },
        { name = "CONFIG_STORAGE_TOPIC", value = "connect_configs" },
        { name = "OFFSET_STORAGE_TOPIC", value = "connect_offsets" },
        { name = "ENABLE_APICURIO_CONVERTERS", value = "true" }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8083/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.connect_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "tumbleweed_user_config_db" {
  family                   = "tumbleweed-user-config-db-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "tumbleweed-user-config-db"
      image = "314146319973.dkr.ecr.us-east-1.amazonaws.com/tumbleweed/postgres:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5432
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.tumbleweed_user_config_db_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "POSTGRES_USER", value = "tumbleweed_user" },
        { name = "POSTGRES_PASSWORD", value = "postgres" },
        { name = "POSTGRES_DB", value = "user_configs" }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "tumbleweed_app" {
  family = "tumbleweed-app-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  execution_role_arn = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name = "tumbleweed-app"
      image = "314146319973.dkr.ecr.us-east-1.amazonaws.com/tumbleweed/tumbleweed-app:1.5"
      essential = true
      portMappings = [
        {
        containerPort = 3001
        protocol = "tcp"
        },
        {
        containerPort = 4001
        protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.tumbleweed_app_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}