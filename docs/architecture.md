# Infrastructure Provisioning (Terraform)

CloudVault infrastructure is fully provisioned using modular Terraform. Each AWS resource is organized into reusable modules, enabling consistent, scalable, and automated deployments.

## AWS Resources Created by Terraform

### Networking
- Amazon VPC
- Internet Gateway
- NAT Gateways
- Elastic IPs
- Public Subnets
- Private Web Subnets
- Private App Subnets
- Private Database Subnets
- Public, Web, App, and Database Route Tables
- Route Table Associations

### Security
- Security Groups
  - Public ALB
  - Internal ALB
  - Web Tier
  - App Tier
  - RDS
  - CI/CD Server

### Identity & Access Management
- IAM Role for EC2
- IAM Instance Profile
- IAM Policies
- S3 Access Policy
- Ansible Dynamic Inventory Policy

### Compute
- CI/CD EC2 Instance
- Launch Templates
- Web Auto Scaling Group
- App Auto Scaling Group

### Load Balancing
#### Public Layer
- Application Load Balancer
- HTTP Listener
- Web Target Group

#### Internal Layer
- Internal Application Load Balancer
- HTTP Listener
- App Target Group

### Database
- Amazon RDS MySQL
- DB Subnet Group

### Storage
- Amazon S3 Bucket
- Bucket Versioning
- Server-Side Encryption
- Public Access Block
- CORS Configuration
- Terraform State S3 Bucket
- SSH Key Upload Object

### Content Delivery
- Amazon CloudFront Distribution

---

# Terraform Module Structure

```text
modules/
├── vpc/
├── security-groups/
├── iam/
├── public-alb/
├── internal-alb/
├── asg/
├── cicd-server/
├── rds/
├── s3/
└── cloudfront/
```

---

# Infrastructure Deployment Flow

```text
Terraform
│
├── VPC & Networking
├── Security Groups
├── IAM
├── S3
├── CloudFront
├── RDS
├── Public ALB
├── Internal ALB
├── Launch Templates
├── Auto Scaling Groups
└── CI/CD EC2

        ↓

Ansible
│
├── Docker
├── Kubernetes (Master & Worker)
├── Jenkins
├── SonarQube
├── Trivy
├── Prometheus
└── Grafana

        ↓

Jenkins CI/CD Pipeline
│
├── Source Code Checkout
├── SonarQube Analysis
├── Docker Build
├── Trivy Image Scan
├── Push Image to Docker Hub
└── Deploy to Kubernetes

        ↓

Kubernetes
│
├── Deployments
├── Services
├── ConfigMaps
├── Secrets
├── Horizontal Pod Autoscaler (HPA)
└── Ingress
```