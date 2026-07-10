# Architecture

## Overview

CloudVault is a cloud-native 3-tier file storage platform built on AWS using Infrastructure as Code (Terraform) and automated with Ansible and Jenkins. The application runs on Kubernetes, stores uploaded files in Amazon S3, and saves file metadata in Amazon RDS MySQL.

The architecture is designed to be modular, secure, scalable, and easy to maintain while keeping AWS costs under control.

---

## Architecture Layers

| Layer | AWS Services | Purpose |
|------|--------------|---------|
| **Edge Layer** | CloudFront | Delivers content with lower latency and reduces load on the application. |
| **Entry Layer** | Public Application Load Balancer | Receives user requests and distributes traffic to the web tier. |
| **Web Layer** | EC2 Auto Scaling Group, Kubernetes Worker Nodes | Hosts the Flask application and automatically scales based on traffic. |
| **Application Layer** | Internal Application Load Balancer, App Auto Scaling Group | Processes application logic and handles internal communication. |
| **Storage Layer** | Amazon S3 | Stores uploaded files securely and provides highly durable object storage. |
| **Database Layer** | Amazon RDS MySQL | Stores file metadata, user information, and application data. |
| **Management Layer** | EC2 (Jenkins, SonarQube) | Builds, tests, scans, and deploys the application automatically. |

---

## Infrastructure Provisioning

All AWS infrastructure is provisioned using reusable Terraform modules.

| Terraform Module | Resources Created |
|------------------|------------------|
| **vpc** | VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway |
| **security-groups** | Security Groups for ALB, EC2, RDS and CI/CD |
| **iam** | IAM Roles, Policies and Instance Profiles |
| **public-alb** | Public Application Load Balancer |
| **internal-alb** | Internal Application Load Balancer |
| **asg** | Launch Templates and Auto Scaling Groups |
| **cicd-server** | Jenkins EC2 Instance |
| **rds** | Amazon RDS MySQL |
| **s3** | Amazon S3 Bucket |
| **cloudfront** | CloudFront Distribution |

---

## Configuration & Deployment

After Terraform creates the infrastructure, Ansible configures all EC2 instances.

| Tool | Purpose |
|------|---------|
| **Ansible** | Server configuration and software installation |
| **Docker** | Containerizes the application |
| **Kubernetes** | Container orchestration |
| **Jenkins** | CI/CD automation |
| **SonarQube** | Static code quality analysis |
| **Trivy** | Container image security scanning |
| **Prometheus** | Metrics collection |
| **Grafana** | Monitoring dashboards |

---

## CI/CD Workflow

```text
GitHub
   │
   ▼
Jenkins
   │
SonarQube Analysis
   │
Docker Build
   │
Trivy Security Scan
   │
Push Image to Docker Hub
   │
Deploy to Kubernetes
```

---

## Kubernetes Components

| Component | Purpose |
|-----------|---------|
| Deployment | Runs application pods |
| Service | Exposes the application inside the cluster |
| Ingress | Routes external traffic to the application |
| Horizontal Pod Autoscaler (HPA) | Automatically scales application pods |
| ConfigMap | Stores application configuration |
| Secret | Stores sensitive information |
| Calico | Provides Kubernetes networking |

---

## Security

CloudVault follows security best practices throughout the infrastructure.

- IAM Roles with least-privilege access
- Security Groups for network isolation
- Private subnets for application and database tiers
- AWS Secrets Manager for sensitive credentials
- SonarQube for source code analysis
- Trivy for container vulnerability scanning
- Encrypted storage using Amazon S3 and Amazon RDS

---

## Monitoring

| Tool | Purpose |
|------|---------|
| Prometheus | Collects infrastructure and application metrics |
| Grafana | Visualizes metrics through dashboards |

---

## Cost Optimization

The infrastructure is designed to minimize AWS costs while remaining scalable.

| Optimization | Benefit |
|-------------|---------|
| Single Availability Zone (Development) | Reduces infrastructure cost during development. |
| Auto Scaling Groups | Launches additional EC2 instances only when required. |
| Kubernetes HPA | Scales application pods based on CPU and memory usage. |
| CloudFront | Reduces repeated requests to backend services. |
| Amazon S3 | Low-cost and highly durable storage for uploaded files. |
| Infrastructure as Code | Prevents unused resources and simplifies cleanup with `terraform destroy`. |
| Modular Terraform | Allows deploying only required infrastructure components. |

---

## Technology Stack

| Category | Technologies |
|----------|--------------|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Configuration Management | Ansible |
| CI/CD | Jenkins |
| Containerization | Docker |
| Orchestration | Kubernetes |
| Monitoring | Prometheus, Grafana |
| Security | IAM, AWS Secrets Manager, SonarQube, Trivy |
| Backend | Python, Flask |
| Database | MySQL (Amazon RDS) |
| Object Storage | Amazon S3 |
| CDN | CloudFront |