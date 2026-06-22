resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-iam"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Agent

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Ansible Dynamic Inventory Permissions

resource "aws_iam_role_policy" "ansible_inventory" {
  name = "${var.project_name}-ansible-inventory"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      }
    ]
  })
}

# EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-iam"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

# S3 Access for Ansible 

resource "aws_iam_role_policy" "s3_key_access" {
  name = "${var.project_name}-s3-key-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::${var.project_name}-file-storage",
          "arn:aws:s3:::${var.project_name}-file-storage/*"
        ]
      }
    ]
  })
}