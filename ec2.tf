resource "aws_key_pair" "demo-key" {
  key_name   = "demo-key"
  public_key = file("${path.module}/demo-key.pub")
}

resource "aws_security_group" "allow-http" {
  name        = "allow-http"
  description = "Allow http from the internet and ssh"

  ingress {
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_iam_role" "EC2Role" {
  name = "EC2Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow"
        "Action" : [
          "sts:AssumeRole"
        ]
        "Principal" : {
          "Service" : [
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "EC2S3Policy" {
  name = "lambdaS3Policy"
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        "Action" : [
          "s3:Get*",
          "s3:List*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::aws-codedeploy-us-east-1/*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "EC2RolePolicyAttachment" {
  policy_arn = aws_iam_policy.EC2S3Policy.arn
  roles      = [aws_iam_role.EC2Role.name]
  name       = "EC2RolePolicyAttachment"
}

resource "aws_iam_instance_profile" "EC2Profile" {
  name = "EC2rofile"
  role = aws_iam_role.EC2Role.name
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "demo-instance" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type

  key_name = aws_key_pair.demo-key.key_name

  security_groups = [aws_security_group.allow-http.name]

  iam_instance_profile = aws_iam_instance_profile.EC2Profile.name

  user_data = filebase64("scripts/user_data.sh")

  tags = {
    Name = "demo-instance"
  }
}

resource "aws_instance" "demo-instance2" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type

  key_name = aws_key_pair.demo-key.key_name

  security_groups = [aws_security_group.allow-http.name]

  iam_instance_profile = aws_iam_instance_profile.EC2Profile.name

  user_data = filebase64("scripts/user_data.sh")

  tags = {
    Name = "demo-instance"
  }
}