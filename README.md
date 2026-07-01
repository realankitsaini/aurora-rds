Markdown# 🚀 Multi-Environment Amazon Aurora RDS with Automated CI/CD

This repository contains a production-ready Infrastructure as Code (IaC) blueprint using **Terraform** to deploy a highly available, securely monitored **Amazon Aurora MySQL Cluster** with a dedicated read replica. 

The project is fully refactored to use **Terraform Workspaces** for multi-environment isolation (`dev`, `staging`, `prod`) and includes a **GitHub Actions CI/CD pipeline** to automate deployments completely hands-free based on Git branch pushes.

---

## 🏗️ Architecture Features

* **Network Isolation:** Configures a dedicated VPC, security groups blocking open internet ingress, and subnets distributed across multiple Availability Zones (AZs) for high availability.
* **Database Layer:** Deploys an Aurora MySQL-compatible cluster consisting of one Primary Writer node and one explicit Read Replica node to scale read performance.
* **Dynamic Sizing:** Uses lookups to automatically scale database instance sizes based on the environment workspace (e.g., small nodes for `dev`, high-performance nodes for `prod`).
* **Automated Observability:** Streams database engine error logs directly to Amazon CloudWatch and sets up performance alarms that trip if CPU utilization spikes past 80%.

---

## 📁 Project File Structure

```text
aurora-rds-project/
├── .github/workflows/
│   └── terraform-pipeline.yml   # The GitHub Actions CI/CD workflow script
├── main.tf                      # Network layer (VPC, Subnets, Security Groups)
├── aurora.tf                    # DB Cluster, Cluster Instances, & CloudWatch Alarms
├── variables.tf                 # Variable declarations and environment lookup maps
├── outputs.tf                   # Exposed connection endpoints (Writer & Reader)
└── .gitignore                   # Safety file preventing local secrets from being tracked
