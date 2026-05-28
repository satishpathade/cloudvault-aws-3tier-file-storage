#!/bin/bash

sudo dnf update -y
sudo dnf install git -y
sudo dnf install tree -y
sudo dnf install python3-pip -y
sudo dnf install ansible -y
pip3 install boto3 botocore
ansible-galaxy collection install amazon.aws