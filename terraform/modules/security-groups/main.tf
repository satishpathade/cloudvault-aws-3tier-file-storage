# public alb sg

resource "aws_security_group" "public_alb" {
  name        = "${var.project_name}-public-alb-sg"
  description = "Public ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# web sg
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web ASG Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from CICD"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.cicd_sg_id]
  }

  # ingress {
  #   description     = "Kubelet API from K8s Master"
  #   from_port       = 10250
  #   to_port         = 10250
  #   protocol        = "tcp"
  #   security_groups = [var.cicd_sg_id]
  # }

  # ingress {
  #   description = "Node to Node"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   self        = true
  # }

  ingress {
    description     = "node-to-node communication"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  # BGP port
  # ingress {
  #   from_port   = 179
  #   to_port     = 179
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.0.0.0/16"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# internal alb sg
resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Internal ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# app sg
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "App Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from CICD"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.cicd_sg_id]
  }

  # ingress {
  #   description     = "Kubelet API from K8s Master"
  #   from_port       = 10250
  #   to_port         = 10250
  #   protocol        = "tcp"
  #   security_groups = [var.cicd_sg_id]
  # }

  # ingress {
  #   description = "Node to Node"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   self        = true
  # }

  ingress {
    description     = "node-to-node communication"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# RDS sg
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "RDS Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      var.cicd_sg_id,
      aws_security_group.web.id,
      aws_security_group.app.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# kubernetes common sg

resource "aws_security_group" "k8s_common" {
  name        = "${var.project_name}-k8s-common-sg"
  description = "Kubernetes cluster communication"
  vpc_id      = var.vpc_id

  # Kubernetes API
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # etcd
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    self        = true
  }

  # Kubelet
  ingress {
    description = "Kubelet"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  # Calico BGP
  ingress {
    description = "Calico BGP"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    self        = true
  }

  # Calico IP-in-IP
  ingress {
    description = "Calico IPIP"
    from_port   = 0
    to_port     = 0
    protocol    = "4"
    self        = true
  }

  egress {
    description = "Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}