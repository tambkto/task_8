output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile.name
}
output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
output "codepipeline_role" {
  value = aws_iam_role.codepipeline-iam-role.arn
}
output "codebuild_role" {
  value = aws_iam_role.codebuild-iam-role.arn
}
output "codedeploy_role" {
  value = data.aws_iam_role.codedeploy-iam-role.arn
}
output "codestar_connection_policy" {
  value = aws_iam_role_policy.codestar_connection_policy.name
}