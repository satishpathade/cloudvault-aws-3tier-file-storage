# CloudVault Deployment & Setup Guide

This comprehensive guide provides step-by-step instructions to provision, configure, deploy, and verify the CloudVault platform in your own AWS environment.

---

## Prerequisites

Ensure your local development machine contains the following accounts and command-line interfaces (CLIs):

* **Cloud Accounts**: Active Accounts for **AWS**, **Docker Hub**, and **GitHub**.
* **Installed CLIs**: `aws`, `terraform`, `ansible`, `git`, `docker`.
* **SSH Configuration**: An active Amazon EC2 Key Pair (`CloudVault-CICD.pem` format) ready in your workspace.

---

## Core Deployment Steps

### 1. Clone the Repository
`git clone https://github.com
cd cloudvault-aws-3tier-devsecops

### 2. Configure AWS Provider Access
Authenticate your terminal session using your programmatic IAM access keys:
```bash
aws configure
```
*Provide your requested `Access Key ID`, `Secret Access Key`, preferred `Default Region`, and `json` as output format.*

### 3. Provision Infrastructure via Terraform
Navigate to your cloud configuration folder to deploy the underlying network and compute layers:
```bash
cd terraform
terraform init
terraform plan
terraform apply --auto-approve
```
*This step provisions your custom VPC, public/private subnets, Application Load Balancer, EC2 instances, S3 storage, and your RDS MySQL cluster.*

### 4. SSH CI/CD Server
    `ssh -i <private-key path> ec2-user@<server-public-ip>`

### 4. Configuration Management via Ansible
Move to your playbook directory to automate server package installation and configurations:
```bash
cd ../ansible
```
1. Open the dynamic inventory file (`inventory.ini` or `hosts`) and populate it with your newly provisioned EC2 instances' IP addresses.
2. Fire the global site playbook configuration:
```bash
ansible-playbook -i inventory.ini playbooks/site.yml
```

---
<!-- 
## Platform & Pipeline Configurations

### 5. Define Jenkins Credentials
To ensure a secure, automated execution flow, log into your Jenkins dashboard and register the following Environment Variables/Credentials in your global store:

| Credential ID | Type | Target Resource Mapping |
| :--- | :--- | :--- |
| `dockerhub-credentials` | Username & Password | Docker Hub central image registry authentication |
| `DB_HOST` | Secret Text | Your generated Amazon RDS endpoint string |
| `DB_NAME` | Secret Text | MySQL target relational database name |
| `DB_USERNAME` | Secret Text | Privileged master database user identity |
| `DB_PASSWORD` | Secret Text | Secure connection passcode for your RDS instance |
| `SECRET_KEY` | Secret Text | Encrypted session token secret key for Flask frontend |
| `AWS_REGION` | Secret Text | Targeted operational AWS cloud deployment region |
| `S3_BUCKET` | Secret Text | Raw object file storage Amazon S3 bucket name |

### 6. Inspect Kubernetes Cluster Topology
Establish an SSH session to your master cluster node control plane and confirm cluster operational readiness:
```bash
kubectl get nodes
kubectl get namespaces
``` -->


<!-- ## Continuous Deployment

### 7. Run the Automated CI/CD Lifecycle
Commit changes or configure a GitHub Webhook to ping your Jenkins instance. Pushing code updates triggers the automated system orchestration sequence:

```text
[ Jenkins Pipeline Execution Workflow ]
 📦 1. Source Checkout  ──> 🔬 2. SonarQube SAST Scan  ──> 🐳 3. Docker Image Build
                                                                    │
 ☸️ 6. K8s Manifest App ──> 🔑 5. ConfigMaps & Secrets ──> 🛑 4. Trivy Vuln Scan
``` -->

---
<!-- 
## 🔎 Verification & Testing

### 8. Inspect Live Namespace Workloads
Validate your live application containers running on isolated pod clusters using the following diagnostic queries:

* **Pod Health Checks**:
  ```bash
  kubectl get pods -n cloudvault -o wide
  ```
* **Networking Status**:
  ```bash
  kubectl get svc -n cloudvault
  ```
* **Deployment Replication**:
  ```bash
  kubectl get deployment -n cloudvault
  ```

### 9. Verify Live Global Traffic Egress
1. Extract your global web distribution routing layer domain endpoint:
   ```text
   https://<your-cloudfront-distribution-id>.cloudfront.net
   ```
2. Open the URL in a web browser interface.
3. Upload a sample file and run back-end logging verifications:
   * ✓ Confirm the raw asset registers within your dedicated **Amazon S3 Storage Bucket**.
   * ✓ Assert metadata rows populate inside your isolated **Amazon RDS MySQL Table**.

---

## 🗑️ Infrastructure Decommissioning

### 10. Clean Cleanup / Teardown
To avoid ongoing AWS cloud subscription charges, clear out your application-allocated storage objects and purge the underlying structural topology:

```bash
# Clean out your S3 files prior to termination running
cd ../terraform
terraform destroy --auto-approve
``` -->