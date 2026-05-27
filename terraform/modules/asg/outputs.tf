# auto scalling group names

output "web_asg_name" {
  value = aws_autoscaling_group.web.name
}

output "app_asg_name" {
  value = aws_autoscaling_group.app.name
}