# Private DNS Namespace for Service Discovery
resource "aws_service_discovery_private_dns_namespace" "kafka" {
  name        = "kafka.local"
  description = "Kafka cluster service discovery namespace"
  vpc         = var.vpc_id
}

# Service Discovery for Controllers
resource "aws_service_discovery_service" "kafka_controller_1" {
  name = "controller-1"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "kafka_controller_2" {
  name = "controller-2"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "kafka_controller_3" {
  name = "controller-3"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

# Service Discovery for Brokers
resource "aws_service_discovery_service" "kafka_broker_1" {
  name = "kafka-1"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "kafka_broker_2" {
  name = "kafka-2"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "kafka_broker_3" {
  name = "kafka-3"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

# Service Discovery for Connect and Apicurio
resource "aws_service_discovery_service" "connect" {
  name = "connect"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "apicurio" {
  name = "apicurio"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "tumbleweed_app" {
  name = "tumbleweed_app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "tumbleweed_config_db" {
  name = "tumbleweed_config_db"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}