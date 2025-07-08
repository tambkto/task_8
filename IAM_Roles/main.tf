terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

//task execution role for ecs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

#IAM role  policy for pulling image from ecr
resource "aws_iam_role_policy_attachment" "ecs_execution_ecr" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "umar_ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_ssm_role" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}
#IAM role policy for EC2 to register with ECS
resource "aws_iam_role_policy_attachment" "ec2_instance_role_ecs_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
#IAM role policy for cloudwatch agent
resource "aws_iam_role_policy_attachment" "ec2_instance_role_cloudwatch_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy" "ec2_instance_efs_policy" {
  name = "role_policy_for_efs"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = "*"
      }
    ]
  })
}
#INSTANCE PROFILE IS created and is used to attach ec2 instance with ec2 role
resource "aws_iam_instance_profile" "instance_profile" {
  name = "umar-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

#importing codepipeline role from AWS Console
data "aws_iam_role" "codepipeline-iam-role" {
  name = "AWSCodePipelineServiceRole-us-east-2-umar-codepipeline"
}
#importing codepibuild role from AWS Console
resource "aws_iam_role" "codebuild-iam-role" {
  name = "umar-codebuild-service-role"
  assume_role_policy =  jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codestar_connection_policy" {
  name = "Allow-git-connection"
  role = aws_iam_role.codebuild-iam-role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:GetConnectionToken",
          "codestar-connections:GetConnection",
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection",
          "codeconnections:UseConnection"
        ],
        Resource = "arn:aws:codestar-connections:us-east-2:504649076991:connection/3a87c06f-a785-4099-a6ba-bd56ec2e18be"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codebuild_artifacts_and_reports_policy" {
  name = "codebuild-s3-reports-policy"
  role = aws_iam_role.codebuild-iam-role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::codepipeline-us-east-2-*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = [
          "arn:aws:codebuild:us-east-2:504649076991:report-group/umar-codebuild-service-role-*"
        ]
      }
    ]
  })
}


#importing codedeploy role from AWS Console
data "aws_iam_role" "codedeploy-iam-role"{
  name = "AWSCodeDeployServiceRole"
}