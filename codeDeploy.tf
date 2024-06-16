# create a service role for codedeploy
resource "aws_iam_role" "codedeployService" {
  name = "codedeployService"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "codedeploy.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "CodeDeployPolicy" {
  name = "CodeDeployPolicy"
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:*",
          "codedeploy:*",
          "ec2:*",
          "lambda:*",
          "elasticloadbalancing:*",
          "iam:AddRoleToInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:CreateRole",
          "iam:DeleteInstanceProfile",
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:GetInstanceProfile",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListInstanceProfilesForRole",
          "iam:ListRolePolicies",
          "iam:ListRoles",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "s3:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeployService" {
  role       = aws_iam_role.codedeployService.name
  policy_arn = aws_iam_policy.CodeDeployPolicy.arn
}

resource "aws_codedeploy_app" "myWebApp" {
  compute_platform = "Server"
  name             = "myWebApp"
}

resource "aws_codedeploy_deployment_group" "myDeploymentGroup" {
  app_name              = aws_codedeploy_app.myWebApp.name
  deployment_group_name = "myDeploymentGroup"
  service_role_arn      = aws_iam_role.codedeployService.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "demo-instance"
    }
  }
}

resource "null_resource" "trigger_deployment" {
  provisioner "local-exec" {
    command = <<EOF
      aws deploy create-deployment --application-name ${aws_codedeploy_app.myWebApp.name} --deployment-group-name ${aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name} --s3-location bucket=my-source-bucket-76sdf700,bundleType=zip,key=webapp.zip
EOF
  }
}
