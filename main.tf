module "vpc" {
  source = "./vpc"
  vpc_cidr = var.vpc-cidr
  cidr_allowing_all = var.cidr-allowing-all
  public_subnet_cidr = var.public-subnet-cidr
  private_subnet_cidr = var.private-subnet-cidr
  owner_name = "Umar"
  providers = {
    aws = aws.ohio
  }
}
module "alb" {
  source = "./alb"
  owner-name = var.ownername
  vpcid = module.vpc.vpc_id
  cidr_allowing_all = var.cidr-allowing-all
  public_subnet = module.vpc.public_subnet
  public_subnet_ids = module.vpc.public_subnet_ids_unique_az

  providers = {
    aws = aws.ohio
  }
}

module "ecs" {
  source = "./ecs"
  cidr_allowing_all = var.cidr-allowing-all
  ec2_ami = var.ec2_ami
  ec2_type = var.ec2_type
  target_group_arn = [module.alb.aws_lb_target_group]
  alb_sg_id = module.alb.alb_sg_id
  asg_desired_capacity = var.asg_desired_capacity
  asg_max_size = var.asg_max_size
  asg_min_size = var.asg_min_size
  instance_profile = module.iam.instance_profile
  vpcid = module.vpc.vpc_id
  private_subnet = module.vpc.private_subnet
  owner_name = var.ownername
  ecs_task_execution_role_arn = module.iam.execution_role_arn
  target-group-arn = module.alb.aws_lb_target_group
  alb-listener-http = module.alb.alb_listener_http

    providers = {
    aws = aws.ohio
  }
}
module "iam" {
  source = "./IAM_Roles"
  providers = {
    aws = aws.ohio
  }
}
module "codepipeline" {
  source = "./codepipeline"
  aws-region = var.aws_region
  asg-name = module.ecs.asg-name
  ecr-repo-uri = module.ecs.ecr-repo-uri
  codebuild_iamrole_arn  = module.iam.codebuild_role
  codedeploy_role_arn = module.iam.codedeploy_role
  codepipeline_role_arn = module.iam.codepipeline_role
  alb-listener = module.alb.alb-listener-arn
  alb-target-group = module.alb.alb-target-group-name
  alb-target-group-2 = module.alb.alb-target-group-2-name
  ecs-cluster-name = module.ecs.ecs-cluster-name
  ecs-service-name = module.ecs.ecs-service-name
  connection-policy = module.iam.codestar_connection_policy
  providers = {
    aws = aws.ohio
  }
  
}