resource "aws_security_group" "ecs_security_group" {
  vpc_id = var.vpc_id
  name = "tumbleweed-ecs-sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port = 3001
    to_port = 3001
    protocol = "tcp"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
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

resource "aws_security_group" "ecr_endpoint_sg" {
  vpc_id = var.vpc_id
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