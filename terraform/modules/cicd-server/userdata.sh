#!/bin/bash

sudo dnf update -y
sudo dnf install git tree python3-pip ansible -y
pip3 install boto3 botocore
ansible-galaxy collection install amazon.aws


sudo xfs_growfs -d /

mkdir -p /home/ec2-user/.ssh

aws s3 cp \
s3://cloudvault-file-storage/cloudvault-cicd.pem \
/home/ec2-user/.ssh/cloudvault-cicd.pem

# ec2-user
sudo chown ec2-user:ec2-user /home/ec2-user/.ssh/cloudvault-cicd.pem
sudo chmod 400 /home/ec2-user/.ssh/cloudvault-cicd.pem

# jenkins user
sudo mkdir -p /var/lib/jenkins/.ssh
sudo cp /home/ec2-user/.ssh/cloudvault-cicd.pem /var/lib/jenkins/.ssh/cloudvault-cicd.pem
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/cloudvault-cicd.pem
sudo chmod 400 /var/lib/jenkins/.ssh/cloudvault-cicd.pem