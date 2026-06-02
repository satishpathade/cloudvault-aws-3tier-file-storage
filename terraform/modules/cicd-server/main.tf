data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# CI/CD Security Group
resource "aws_security_group" "cicd" {
  name        = "${var.project_name}-cicd-sg"
  description = "Security group for CI/CD server"
  vpc_id      = var.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins port
  ingress {
    description = "Jenkins"

    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube port
  ingress {
    description = "SonarQube"

    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # k8s API port
  ingress {
    description = "kubernetes API"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  # kubelet port
  ingress {
    description = "kubelet"
    from_port = 10250
    to_port =10250
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-cicd-sg"
  }
}

# CI/CD EC2 Instance

resource "aws_instance" "cicd_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.cicd_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.cicd.id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true
  
  # userdata script to install ansible
  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name    = "${var.project_name}-cicd-server"
    Project = var.project_name
  }
}
