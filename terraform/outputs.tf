output "public_alb_dns" {
  value = module.public_alb.alb_dns_name
}

output "internal_alb_dns" {
  value = module.internal_alb.alb_dns_name
}

output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}