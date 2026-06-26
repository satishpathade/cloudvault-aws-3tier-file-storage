# CloudVault AWS Cloud-Native 3-Tier Infrastructure

The architecture separates components into Presentation, Application, and Database tiers to improve security, scalability, and maintainability.

## Architecture Components

### Networking layer

**Amazon VPC**
A dedicated Virtual Private Cloud (VPC) provides network isolation for all infrastructure component.

VPC CIDR : `10.0.0.0/16`
Region : `ap-south-1`

**Subnet Design**
The infrastructure is divided into multiple subnet tiers.

| Subnet Type | CIDR Block | Purpose | Network Exposure |
| :--- | :--- | :--- | :--- |
| **Public Subnet 1** | `10.0.0.0/20` | Application Load Balancer (AZ 1) | Public (Internet Facing) |
| **Public Subnet 2** | `10.0.16.0/20` | Application Load Balancer (AZ 2) | Public (Internet Facing) |
| **Web Subnet 1** | `10.0.32.0/20` | Kubernetes Worker Nodes (AZ 1) | Private (No Direct IGW) |
| **Web Subnet 2** | `10.0.48.0/20` | Kubernetes Worker Nodes (AZ 2) | Private (No Direct IGW) |
| **App Subnet 1** | `10.0.64.0/20` | Application Services (AZ 1) | Private (Internal Only) |
| **App Subnet 2** | `10.0.80.0/20` | Application Services (AZ 2) | Private (Internal Only) |
| **Database Subnet 1** | `10.0.96.0/20` | Amazon RDS Primary Instance | Private (Isolated) |
| **Database Subnet 2** | `10.0.112.0/20` | Amazon RDS Standby Instance | Private (Isolated) |

###

### Database Tier
**Amazon RDS MySQL**
CloudVault stores all files metadata inside Amazon RDS MySQL

| Stored Information | Features | Security |
| :--- | :--- | :--- |
| • File names | • Managed DB service | • Private subnets |
| • File URLs | • Multi-AZ deployment | • Restricted security groups |
| • Upload timestamps | • Automated backups | • No internet exposure |
| • User metadata | • Automatic failover | • Private access layer |