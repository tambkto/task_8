terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
resource "aws_codepipeline" "codepipeline" {
  name     = "umar-task8-pipeline"
  role_arn = var.codepipeline_role_arn // has to add role in IAM module.
  pipeline_type = "V2"
  artifact_store {
    location = aws_s3_bucket.umar-codepipeline-bucket.bucket
    type     = "S3" 
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github-connection.arn
        FullRepositoryId = "tambkto/task_8"
        BranchName       = "main"
      }
    }
  }
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "umar-codebuild-project"
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.codedeploy_app.name
        DeploymentGroupName = "umar-codepipeline-deployment-group"
      }
    }
  }
}

resource "aws_s3_bucket" "umar-codepipeline-bucket" {
  bucket = "umar-codepipeline-bucket-task-8"
  tags = {
    Name = "umar-bucket-codepipeline-task-8"
  }
}
resource "aws_codestarconnections_connection" "github-connection" {
  name = "umar-connection-github-2"
  provider_type = "GitHub"
}
resource "aws_codebuild_project" "codebuild-project" {
  name         = "umar-codebuild-project"
  service_role = var.codebuild_iamrole_arn        //attach codebuild service role here from IAM module.

  artifacts {
    type = "CODEPIPELINE"
  }
  depends_on = [
  var.connection-policy
]


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name = "ECR_REPO_URI"
      value = var.ecr-repo-uri
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = var.aws-region
    }
    environment_variable {
      name = "TASK_FAMILY"
      value = "Umar_task_definition"
    }
    
  }
  logs_config {
    cloudwatch_logs {
      group_name = var.cloudwatch_log_group
      stream_name = "build-logs"
      status = "ENABLED"
    }
  }

  source {
    type     = "CODEPIPELINE"
    # location = "https://github.com/tambkto/task_8.git"
    # auth {
    #   type     = "CODECONNECTIONS"
    #   resource = aws_codestarconnections_connection.github-connection.arn //using connection from above.
    # }
  }
}

resource "aws_codedeploy_app" "codedeploy_app" {
  name = "umar-codedeploy-app"
  compute_platform = "ECS"
}
resource "aws_codedeploy_deployment_group" "example" {
  app_name               = aws_codedeploy_app.codedeploy_app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "umar-codepipeline-deployment-group"
  service_role_arn       = var.codedeploy_role_arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs-cluster-name
    service_name = var.ecs-service-name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.alb-listener]
      }

      target_group {
        name = var.alb-target-group
      }

      target_group {
        name = var.alb-target-group-2
      }
    }
  }
}
