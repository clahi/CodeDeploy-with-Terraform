#!/bin/bash

sudo yum update

sudo yum install ruby -y

sudo yum install wget -y

sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

sudo chmod +x install

sudo ./install auto

sudo systemctl start codedeploy-agent

sudo systemctl enable codedeploy-agent