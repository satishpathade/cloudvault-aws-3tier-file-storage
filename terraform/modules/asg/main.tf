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

# Web Launch Template

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.web_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.web_sg_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-web-server"
      Project = var.project_name
    }
  }
}

# Web ASG
resource "aws_autoscaling_group" "web" {
  name             = "${var.project_name}-web-asg"
  desired_capacity = var.web_desired_size
  min_size         = var.web_min_size
  max_size         = var.web_max_size
  force_delete     = true

  vpc_zone_identifier = var.web_subnet_ids

  target_group_arns = [var.web_tg_arn]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# App Launch Template

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-app-server"
      Project = var.project_name
    }
  }
}

# App ASG
resource "aws_autoscaling_group" "app" {
  name             = "${var.project_name}-app-asg"
  desired_capacity = var.app_desired_size
  min_size         = var.app_min_size
  max_size         = var.app_max_size
  force_delete     = true

  vpc_zone_identifier = var.app_subnet_ids

  target_group_arns = [var.web_tg_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}
