output "public_alb_sg_id" {
  value = aws_security_group.public_alb.id
}

output "web_sg_id" {
  value = aws_security_group.web.id
}