module "vpc" {
  source              = "./modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnet_cidrs = var.public_subnet_cidrs
  web_subnet_cidrs    = var.web_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  tags                = var.tags
}

module "security_groups" {
  source       = "./modules/security-groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  tags         = var.tags
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  tags         = var.tags
}

module "public_alb" {
  source            = "./modules/public-alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.public_alb_sg_id
  tags              = var.tags
}

module "internal_alb" {
  source       = "./modules/internal-alb"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.web_subnet_ids
  alb_sg_id    = module.security_groups.internal_alb_sg_id
  tags         = var.tags
}

module "asg" {
  source       = "./modules/asg"
  project_name = var.project_name
  tags         = var.tags

  web_subnet_ids = module.vpc.web_subnet_ids
  app_subnet_ids = module.vpc.app_subnet_ids

  web_sg_id = module.security_groups.web_sg_id
  app_sg_id = module.security_groups.app_sg_id

  web_instance_type = var.web_instance_type
  app_instance_type = var.app_instance_type

  web_min_size     = var.web_min_size
  web_desired_size = var.web_desired_size
  web_max_size     = var.web_max_size

  app_min_size     = var.app_min_size
  app_desired_size = var.app_desired_size
  app_max_size     = var.app_max_size

  key_name              = var.key_name
  instance_profile_name = module.iam.instance_profile_name
  
  web_tg_arn = module.public_alb.web_tg_arn
  k8s_common_sg_id = module.security_groups.k8s_common_sg_id
}

module "cicd_server" {
  source                = "./modules/cicd-server"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_ids[0]
  cicd_instance_type    = var.cicd_instance_type
  key_name              = var.key_name
  instance_profile_name = module.iam.instance_profile_name
  cicd_sg_id            = module.security_groups.cicd_sg_id
  k8s_common_sg_id      = module.security_groups.k8s_common_sg_id
}

module "rds" {
  source       = "./modules/rds"
  project_name = var.project_name

  db_subnet_ids = module.vpc.db_subnet_ids
  rds_sg_id     = module.security_groups.rds_sg_id

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  tags              = var.tags
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  tags         = var.tags
}

resource "aws_s3_object" "ansible_key" {
  bucket = module.s3.bucket_name
  key    = "CloudVault-CICD.pem"
  source = "${path.module}/keys/CloudVault-CICD.pem"
}

module "cloudfront" {
  source          = "./modules/cloudfront"
  project_name    = var.project_name
  origin_dns_name = module.public_alb.alb_dns_name
  tags            = var.tags
}

module "secrets_manager" {
  source = "./modules/secrets-manager"
  project_name = var.project_name

  db_host     = module.rds.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  secret_key = var.secret_key
  aws_region = var.aws_region
  s3_bucket  = module.s3.bucket_name
  tags = var.tags
}