terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.17.0" }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_iam_role" "consumer_access_role" {
  name = "app-consumer-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::314146319973:user/nickyp"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "consumer_access_policy" {
  name = "consumer-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:StartTask",
          "ec2:DescribeNetworkInterfaces",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken", 
          "ecr:BatchCheckLayerAvailability", 
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "ecs-task-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_consumer_policy" {
  role       = aws_iam_role.consumer_access_role.name
  policy_arn = aws_iam_policy.consumer_access_policy.arn
}

# Define ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "tumbleweed-cluster"
}

# Define ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach ECS Task Execution Policy
resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Define IAM Role for ECS Container Instances (EC2)
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRoleTumbleweed"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach ECS Instance Role Policy
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Instance Profile for ECS Instance
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

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

resource "aws_ecs_task_definition" "kafka_controller_1" {
  family                   = "kafka-controller-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-1"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093  # Kafka's controller port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_controller_1_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "1" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        # { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@kafka-controller-1.kafka.local:9093,2@kafka-controller-2.kafka.local:9093,3@kafka-controller-3.kafka.local:9093" },  # Use DNS names
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
  family                   = "kafka-controller-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-2"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093  # Kafka's controller port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_controller_2_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "2" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        # { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@kafka-controller-1.kafka.local:9093,2@kafka-controller-2.kafka.local:9093,3@kafka-controller-3.kafka.local:9093" },  # Use DNS names
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
  family                   = "kafka-controller-task"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kraft-controller-3"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9093  # Kafka's controller port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_controller_3_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "3" },
        { name = "KAFKA_PROCESS_ROLES", value = "controller" },
        # { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@kafka-controller-1.kafka.local:9093,2@kafka-controller-2.kafka.local:9093,3@kafka-controller-3.kafka.local:9093" },  # Use DNS names
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
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

resource "aws_ecs_task_definition" "kafka_broker_1" {
  family                   = "kafka-broker-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "kafka-broker-1"
      image     = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9092  # Kafka's internal port
          protocol      = "tcp"
        },
        {
          containerPort = 19092  # External port for PLAINTEXT
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_broker_1_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "4" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        # { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-1:19092,PLAINTEXT_HOST://localhost:29092" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-broker-1.kafka.local:19092,PLAINTEXT_HOST://localhost:29092" },
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
  family                   = "kafka-broker-2-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "kafka-broker-2"
      image = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9092  # Kafka's internal port
          protocol      = "tcp"
        },
        {
          containerPort = 19092  # External port for PLAINTEXT
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_broker_2_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "5" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        # { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-3:19092,PLAINTEXT_HOST://localhost:39092" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-broker-2.kafka.local:19092,PLAINTEXT_HOST://localhost:39092" },
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
  family                   = "kafka-broker-3-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([
    {
      name = "kafka-broker-3"
      image = "apache/kafka:3.9.0"
      essential = true
      portMappings = [
        {
          containerPort = 9092  # Kafka's internal port
          protocol      = "tcp"
        },
        {
          containerPort = 19092  # External port for PLAINTEXT_HOST
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.kafka_broker_3_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "KAFKA_NODE_ID", value = "6" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@controller-1:9093,2@controller-2:9093,3@controller-3:9093" },
        { name = "KAFKA_LISTENERS", value = "PLAINTEXT://:19092,PLAINTEXT_HOST://:9092" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "PLAINTEXT" },
        # { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-3:19092,PLAINTEXT_HOST://localhost:49092" },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "PLAINTEXT://kafka-broker-3.kafka.local:19092,PLAINTEXT_HOST://localhost:49092" },
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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

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
          "awslogs-group"         = aws_cloudwatch_log_group.apicurio_registry_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
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
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "connect-debezium"
      image     = "debezium/connect:3.0.0.Final"
      essential = true
      portMappings = [
        { containerPort = 8083 }
      ]
      environment = [
        { "name" = "BOOTSTRAP_SERVERS", "value" = "kafka-1:19092,kafka-2:19092,kafka-3:19092" },
        { "name" = "GROUP_ID", "value" = "1" },
        { "name" = "CONFIG_STORAGE_TOPIC", "value" = "connect_configs" },
        { "name" = "OFFSET_STORAGE_TOPIC", "value" = "connect_offsets" },
        { "name" = "ENABLE_APICURIO_CONVERTERS", "value" = "true" }
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
          "awslogs-group"         = aws_cloudwatch_log_group.connect_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "tumbleweed-user-config-db"
      image = "314146319973.dkr.ecr.us-east-1.amazonaws.com/tumbleweed/tumbleweed-app:latest"
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
          "awslogs-group"         = aws_cloudwatch_log_group.tumbleweed_user_config_db_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "POSTGRES_USER", value = "postgres" },
        { name = "POSTGRES_PASSWORD", value = "postgres" },
        { name = "POSTGRES_DB", value = "userconfig" }
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
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name = "tumbleweed-app"
      image = "314146319973.dkr.ecr.us-east-1.amazonaws.com/tumbleweed/tumbleweed-app@sha256:0f2b8e67969e9414956a802a2cd9b1eb50d78d3067754e6e0de3128ce3086b6b"
      essential = true
      portMappings = [
        {
        containerPort = 3001
        protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.tumbleweed_app_log_group.name
          "awslogs-region"        = "us-east-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "tumbleweed-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "tumbleweed-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.igw.id  # Route traffic to the Internet Gateway
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.main.id
  name = "tumbleweed-ecs-sg"

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed
  }

  ingress {
    from_port   = 19092
    to_port     = 19092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed
  }

  ingress {
    from_port = 3001
    to_port = 3001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 3001
    to_port = 3001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tumbleweed-ecs-sg"
  }
}

# resource "aws_security_group" "database_security_group" {
#   vpc_id = aws_vpc.main.id
#   name = "tumbleweed-database-sg"

#   ingress {
#     from_port = 5432
#     to_port = 5432
#     protocol = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "tumbleweed-database-sg"
#   }
# }

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "tumbleweed-private-subnet"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ecs_security_group.id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ecs_security_group.id]
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.private_subnet.id]
  security_group_ids = [aws_security_group.ecs_security_group.id]
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  associate_with_private_ip = true
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Update Route Table for private subnet to use NAT
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "tumbleweed-private-route-table"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "ecr_endpoint_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ecr-endpoint-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Your private subnet's CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_service_discovery_private_dns_namespace" "kafka_namespace" {
  name        = "kafka.local"  # Choose a suitable name
  vpc         = aws_vpc.main.id
  description = "Service discovery namespace for Kafka brokers"
}

resource "aws_service_discovery_service" "kafka_service" {
  name = "kafka-service"

  namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_namespace.id

    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# Create ECS Services for Kafka Controllers
resource "aws_ecs_service" "kafka_controller_1" {
  name            = "kafka-controller-1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_1.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]  # Change to private subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false  # Set to false for private subnet
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}

resource "aws_ecs_service" "kafka_controller_2" {
  name            = "kafka-controller-2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_2.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]  # Change to private subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false  # Set to false for private subnet
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}

resource "aws_ecs_service" "kafka_controller_3" {
  name            = "kafka-controller-3"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_controller_3.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]  # Change to private subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false  # Set to false for private subnet
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}


# # Create ECS Services for Kafka Controllers
# resource "aws_ecs_service" "kafka_controller_1" {
#   name            = "kafka-controller-1"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_controller_1.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.public_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = true
#   }
# }

# resource "aws_ecs_service" "kafka_controller_2" {
#   name            = "kafka-controller-2"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_controller_2.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.public_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = true
#   }
# }

# resource "aws_ecs_service" "kafka_controller_3" {
#   name            = "kafka-controller-3"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_controller_3.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.public_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = true
#   }
# }

# Create ECS Services for Kafka Brokers
# resource "aws_ecs_service" "kafka_broker_1" {
#   name            = "kafka-broker-1"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_broker_1.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.private_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = false
#   }

#   service_registries {
#     registry_arn = aws_service_discovery_private_dns_namespace.kafka_namespace.arn
#   }
# }

# resource "aws_ecs_service" "kafka_broker_2" {
#   name            = "kafka-broker-2"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_broker_2.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [aws_subnet.public_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = true
#   }
# }

# resource "aws_ecs_service" "kafka_broker_3" {
#   name            = "kafka-broker-3"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.kafka_broker_3.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
  
#   network_configuration {
#     subnets          = [aws_subnet.public_subnet.id]
#     security_groups  = [aws_security_group.ecs_security_group.id]
#     assign_public_ip = true
#   }
# }

# Create ECS Services for Kafka Brokers
resource "aws_ecs_service" "kafka_broker_1" {
  name            = "kafka-broker-1"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_1.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}

resource "aws_ecs_service" "kafka_broker_2" {
  name            = "kafka-broker-2"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_2.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}

resource "aws_ecs_service" "kafka_broker_3" {
  name            = "kafka-broker-3"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.kafka_broker_3.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.kafka_service.arn
  }
}

# Create ECS Service for Apicurio Registry
resource "aws_ecs_service" "apicurio_registry" {
  name            = "apicurio-registry"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.apicurio_registry.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]  # Reference your subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}

# Create ECS Service for Connect Debezium
resource "aws_ecs_service" "connect" {
  name            = "connect-debezium"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.connect.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]  # Reference your subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}

# Create ECS Service for Tumbleweed User Config DB
resource "aws_ecs_service" "tumbleweed_user_config_db" {
  name            = "tumbleweed-user-config-db"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tumbleweed_user_config_db.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]  # Reference your subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}

# Create ECS Service for Tumbleweed App
resource "aws_ecs_service" "tumbleweed_app" {
  name            = "tumbleweed-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tumbleweed_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]  # Reference your subnet
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}