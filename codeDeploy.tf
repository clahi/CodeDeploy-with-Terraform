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

# attach AWS managed policy called AWSCodeDeployRole
# required for deployments which are to an EC2 compute platform
resource "aws_iam_role_policy_attachment" "codedeployService" {
  role       = aws_iam_role.codedeployService.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
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

# resource "aws_codedeploy_deployment" "myDeployment" {
#   application_name      = aws_codedeploy_app.name
#   deployment_group_name = aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name
#   revision {
#     revision_type = "S3"

#     s3_location {
#       bucket      = "s3://my-source-bucket-76sdf700"
#       key         = "webapp.zip"
#       bundle_type = "zip"
#     }
#   }
# }

# resource "null_resource" "trigger_deployment" {
#   provisioner "local-exec" {
#     command = <<EOF
#     aws deploy create-deployment \
#         --application-name ${aws_codedeploy_app.myWebApp.name} \
#         --deployment-group-name ${aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name} \
#         --s3-location bucket=my-source-bucket-76sdf700,key=webapp.zip,bundleType=zip
# EOF
#   }
# }

resource "null_resource" "trigger_deployment" {
  provisioner "local-exec" {
    command = <<EOF
echo "Deploying application using AWS CLI..."
echo "aws deploy create-deployment --application-name ${aws_codedeploy_app.myWebApp.name} --deployment-group-name ${aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name} --s3-location bucket=my-source-bucket-76sdf700,key=webapp.zip,bundleType=zip"
aws deploy create-deployment --application-name ${aws_codedeploy_app.myWebApp.name} --deployment-group-name ${aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name} --s3-location bucket=my-source-bucket-76sdf700,key=webapp.zip,bundleType=zip
EOF
  }

  triggers = {
    app_name              = aws_codedeploy_app.myWebApp.name
    deployment_group_name = aws_codedeploy_deployment_group.myDeploymentGroup.deployment_group_name
    s3_bucket             = "my-source-bucket-76sdf700"
    s3_key                = "webapp.zip"
  }
}