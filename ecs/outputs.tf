output "ec2_sg" {
  value = aws_security_group.sg_ec2.id
}
output "asg-name" {
  value = aws_autoscaling_group.asg.name
}
output "ecr-repo-uri" {
  value = aws_ecr_repository.nginx_repo.repository_url
}
output "ecs-cluster-name" {
  value = aws_ecs_cluster.ecs_cluster.name
}
output "ecs-service-name" {
  value = aws_ecs_service.service.name
}