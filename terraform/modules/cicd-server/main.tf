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

# CI/CD EC2 Instance

resource "aws_instance" "cicd_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.cicd_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.cicd_sg_id, var.k8s_common_sg_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true
  
  # userdata script to install ansible
  user_data = file("${path.module}/userdata.sh")

  # change root volume
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.project_name}-cicd-server"
    Project = var.project_name
  }
}
