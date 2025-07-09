variable "asg-name" {
  type = string
}
variable "codepipeline_role_arn" {
  type = string
}
variable "codebuild_iamrole_arn" {
  type = string
}
variable "ecr-repo-uri" {
  type = string
}
variable "aws-region" {
  type = string
}
variable "codedeploy_role_arn" {
  type = string
}
variable "ecs-cluster-name" {
  type = string
}
variable "ecs-service-name" {
  type = string
}
variable "alb-listener" {
  type = string
}
variable "alb-target-group" {
  type = string
}
variable "alb-target-group-2" {
  type = string
}
variable "connection-policy" {
  type = string
}
variable "cloudwatch_log_group" {
  type = string
}