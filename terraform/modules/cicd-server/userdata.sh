#!/bin/bash

sudo dnf update -y
sudo dnf install git tree python3-pip ansible -y
pip3 install boto3 botocore
ansible-galaxy collection install amazon.aws


sudo -u ec2-user git clone https://github.com/satishpathade/cloudvault-aws-3tier-devsecops.git

sudo xfs_growfs -d /

mkdir -p /home/ec2-user/.ssh

aws s3 cp \
s3://cloudvault-file-storage/CloudVault-CICD.pem \
/home/ec2-user/.ssh/CloudVault-CICD.pem

# ec2-user private key permission
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/CloudVault-CICD.pem
sudo chmod 400 /home/ec2-user/.ssh/CloudVault-CICD.pem
