output "cicd_server_id" {
  value = aws_instance.cicd_server.id
}

output "cicd_public_ip" {
  value = aws_instance.cicd_server.public_ip
}

output "cicd_private_ip" {
  value = aws_instance.cicd_server.private_ip
}

output "cicd_security_group_id" {
  value = aws_security_group.cicd.id
}