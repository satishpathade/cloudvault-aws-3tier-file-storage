#!/bin/bash

sudo dnf update -y
sudo dnf install git -y
sudo dnf install tree -y
sudo dnf install python3-pip -y
sudo dnf install ansible -y
pip3 install boto3 botocore
ansible-galaxy collection install amazon.aws

mkdir -p /home/ec2-user/.ssh

aws s3 cp \
s3://cloudvault-file-storage/cloudvault-cicd.pem \
/home/ec2-user/.ssh/cloudvault-cicd.pem

chmod 400 /home/ec2-user/.ssh/cloudvault-cicd.pem

chown ec2-user:ec2-user \
/home/ec2-user/.ssh/cloudvault-cicd.pem