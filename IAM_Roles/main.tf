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
 resource "aws_iam_role" "codepipeline-iam-role" {
  name = "umar-codepipeline-service-role-2"
  assume_role_policy =  jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "umar-codepipeline-service-role-policy"
  role = aws_iam_role.codepipeline-iam-role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Statement1",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::umar-codepipeline-bucket-task-8",
          "arn:aws:s3:::umar-codepipeline-bucket-task-8/*"
        ]
      },
      {
        "Sid": "Statement2",
        "Effect": "Allow",
        "Action": "ecs:*",
        "Resource": "*"
      },
      {
        "Sid": "Statement3",
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "arn:aws:iam::504649076991:role/ecsTaskExecutionRole2"
      },
      {
        "Sid": "Statement4",
        "Effect": "Allow",
        "Action": "ecr:*",
        "Resource": "*"
      },
      {
        "Sid": "Statement5",
        "Effect": "Allow",
        "Action": [
          "codestar-connections:UseConnection"
        ],
        "Resource": "arn:aws:codestar-connections:us-east-2:504649076991:connection/1bb6327e-7e4f-4ac7-9148-4eb4cc4712f3"
      },
      {
        "Sid": "Statement6",
        "Effect": "Allow",
        "Action": "codedeploy:*",
        "Resource": "*"
      },
      {
        "Sid": "Statement7",
        "Effect": "Allow",
        "Action": [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Statement8",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  })
}
#importing codepibuild role from AWS Console
resource "aws_iam_role" "codebuild-iam-role" {
  name = "umar-codebuild-service-role-2"
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
  name = "codebuild-all-policies"
  role = aws_iam_role.codebuild-iam-role.id
  policy = jsonencode({
    
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Action": "ecr:*",
      "Resource": "*"
    },
    {
      "Sid": "Statement2",
      "Effect": "Allow",
      "Action": "codestar-connections:*",
      "Resource": "*"
    },
    {
      "Sid": "Statement3",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Sid": "Statement4",
      "Effect": "Allow",
      "Action": "codebuild:*",
      "Resource": "*"
    },
    {
      "Sid": "Statement5",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },{
        "Sid": "Statement7",
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "arn:aws:iam::504649076991:role/ecsTaskExecutionRole2"
      },
    {
      "Sid": "Statement6",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition"
      ],
      "Resource": "*"
    }

  ]

  })
}



#importing codedeploy role from AWS Console
data "aws_iam_role" "codedeploy-iam-role"{
  name = "AWSCodeDeployServiceRole"
}