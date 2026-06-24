#!/bin/bash

sudo dnf update -y
sudo dnf install -y git tree python3-pip ansible

pip3 install boto3 botocore
ansible-galaxy collection install amazon.aws

# Expand root volume
sudo xfs_growfs -d /

# Clone repository

cd /home/ec2-user
sudo -u ec2-user git clone https://github.com/satishpathade/cloudvault-aws-3tier-file-storage.git

# Create SSH directory
mkdir -p /home/ec2-user/.ssh

# Download private key from S3
aws s3 cp \
s3://cloudvault-file-storage/CloudVault-CICD.pem \
/home/ec2-user/.ssh/CloudVault-CICD.pem

# Set ownership and permissions
chown ec2-user:ec2-user /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh/CloudVault-CICD.pem

chmod 700 /home/ec2-user/.ssh
chmod 400 /home/ec2-user/.ssh/CloudVault-CICD.pem