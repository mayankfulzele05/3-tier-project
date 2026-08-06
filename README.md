<div align="center">

# 🚀 Production-Ready 3-Tier Application Deployment on Amazon EKS

### End-to-End DevOps Implementation using Terraform, GitHub Actions, GitHub OIDC, Kubernetes, Docker, Route 53, ACM & Grafana Observability Stack

<p align="center">

![AWS](https://img.shields.io/badge/AWS-EKS-orange?style=for-the-badge&logo=amazonaws)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?style=for-the-badge&logo=githubactions)
![Grafana](https://img.shields.io/badge/Grafana-Observability-F46800?style=for-the-badge&logo=grafana)
![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=for-the-badge&logo=prometheus)
![Loki](https://img.shields.io/badge/Loki-Logs-F2CC0C?style=for-the-badge)
![Tempo](https://img.shields.io/badge/Tempo-Tracing-7B42BC?style=for-the-badge)
![Terraform](https://img.shields.io/badge/Infrastructure-Automation-623CE4?style=for-the-badge)

</p>

---

## 🌟 Project Overview

This project demonstrates a **complete enterprise-grade DevOps implementation** for deploying a modern **3-Tier Web Application** on **Amazon Elastic Kubernetes Service (EKS)**.

Unlike a traditional Kubernetes deployment, this project focuses on the **complete Software Delivery Lifecycle**, starting from infrastructure provisioning to secure production deployment and observability.

The complete AWS infrastructure is provisioned using **Terraform**, ensuring repeatable and version-controlled deployments. Authentication between **GitHub Actions** and **AWS** is securely implemented using **GitHub OIDC**, eliminating the need for long-lived AWS access keys.

The application is deployed through **two independent CI/CD pipelines**:

- ✅ QA Pipeline
- ✅ Production Pipeline

The deployment follows an enterprise promotion strategy where code is first deployed to the **QA environment** for testing before being promoted to the **Production environment**.

The application is exposed through a **custom domain** purchased separately and configured using **Amazon Route 53**, while **AWS Certificate Manager (ACM)** provides secure HTTPS communication.

The project also includes a complete **Grafana Observability Stack**, enabling centralized monitoring, logging, and distributed tracing for Kubernetes workloads.

---

# ✨ Key Features

## ☁ Infrastructure as Code

- Complete AWS infrastructure provisioned using Terraform
- Modular Terraform configuration
- Version-controlled infrastructure
- Automated provisioning

---

## 🔐 Secure Authentication

- GitHub OIDC Authentication
- IAM Roles
- IRSA (IAM Roles for Service Accounts)
- No AWS Access Keys used

---

## 🚀 CI/CD

- GitHub Actions
- QA Pipeline
- Production Pipeline
- Docker Image Promotion
- Automated Kubernetes Deployment

---

## ☸ Kubernetes

- Amazon EKS
- Namespaces
- Deployments
- Services
- StatefulSets
- Ingress
- ConfigMaps
- Secrets

---

## 🌐 Networking

- AWS Load Balancer Controller
- Application Load Balancer (ALB)
- Route53
- Custom Domain
- HTTPS

---

## 🔑 Secrets Management

- AWS Secrets Manager
- External Secrets Operator
- Kubernetes Secrets
- Secure Secret Synchronization

---

## 🗄 Database

- MySQL StatefulSet
- Persistent Volumes
- Persistent Volume Claims

---

## 📊 Complete Observability Stack

- Prometheus
- Grafana
- Loki
- Tempo
- Grafana Alloy

---

## 🏗 High-Level Architecture

```text
                      Developer
                          │
                          │ Git Push
                          ▼
                     GitHub Repository
                          │
                          │
                GitHub Actions Workflows
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
          QA Pipeline              Production Pipeline
                │                         │
                └────────────┬────────────┘
                             │
                        GitHub OIDC
                             │
                             ▼
                           AWS IAM
                             │
                             ▼
                     Terraform Apply
                             │
      ┌───────────────────────────────────────────────┐
      │                 AWS Infrastructure            │
      │                                               │
      │   VPC                                         │
      │   Public Subnets                              │
      │   Private Subnets                             │
      │   Security Groups                             │
      │   Internet Gateway                            │
      │   Amazon EKS Cluster                          │
      │   Managed Node Groups                         │
      └───────────────────────────────────────────────┘
                             │
                             ▼
                    Kubernetes Cluster
                             │
      ┌──────────────┬──────────────┬──────────────┐
      │              │              │
      ▼              ▼              ▼
  React App     Node.js API      MySQL DB
      │              │
      └───────┬──────┘
              ▼
     AWS Load Balancer Controller
              │
              ▼
      Application Load Balancer
              │
              ▼
           Route53 DNS
              │
              ▼
        ACM HTTPS Certificate
              │
              ▼
        Custom Domain Access

──────────────────────────────────────────────

Observability Stack

Application
     │
     ▼
Grafana Alloy
     │
 ┌───┼───────────────┐
 │   │               │
 ▼   ▼               ▼
Prometheus        Loki        Tempo
 │                │             │
 └──────┬─────────┴─────────────┘
        ▼
      Grafana
```

---

# 🛠 Technology Stack

| Category | Technology |
|-----------|------------|
| Cloud Provider | Amazon Web Services (AWS) |
| Infrastructure as Code | Terraform |
| Authentication | GitHub OIDC |
| Version Control | GitHub |
| CI/CD | GitHub Actions |
| Containerization | Docker |
| Container Registry | Docker Hub |
| Orchestration | Amazon Elastic Kubernetes Service (EKS) |
| Package Manager | Helm |
| Ingress | AWS Load Balancer Controller |
| DNS | Amazon Route53 |
| SSL | AWS Certificate Manager |
| Secrets | AWS Secrets Manager |
| Secret Synchronization | External Secrets Operator |
| Database | MySQL |
| Frontend | React |
| Backend | Node.js |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Logging | Loki |
| Tracing | Tempo |
| Telemetry Collector | Grafana Alloy |

---

# 📑 Table of Contents

- Project Overview
- Features
- Architecture
- Technology Stack
- Infrastructure Provisioned using Terraform
- GitHub OIDC Authentication
- Docker Workflow
- Kubernetes Deployment
- QA Environment
- Production Environment
- GitHub Actions CI/CD
- AWS Load Balancer Controller
- Route53 & ACM
- External Secrets
- AWS Secrets Manager
- MySQL StatefulSet
- Prometheus Monitoring
- Grafana Dashboards
- Loki Logging
- Tempo Tracing
- Grafana Alloy
- Deployment Walkthrough
- Troubleshooting
- Future Enhancements
- Author

---

---

# ☁️ Infrastructure Provisioned with Terraform

All cloud infrastructure required for the application is provisioned using **Terraform**, ensuring a fully automated, repeatable, and version-controlled deployment.

The following resources are created:

### 🚀 Amazon EKS
- Amazon EKS Cluster
- Managed Node Group
- IAM Roles & Policies
- Kubernetes & Helm Provider Configuration

### 🔐 GitHub OIDC
- GitHub OpenID Connect (OIDC) Provider
- IAM Role for GitHub Actions
- Secure AWS authentication without storing access keys

### 🌐 AWS Load Balancer Controller
- IAM Role using IRSA
- Helm installation of AWS Load Balancer Controller
- Automatic provisioning of Application Load Balancers (ALB) for Kubernetes Ingress resources

### 🔑 AWS Secrets Manager
- AWS Secrets Manager integration
- IAM permissions for secure secret access
- External Secrets Operator deployment using Helm

### 🗄️ MySQL
- Kubernetes manifests deploy a MySQL StatefulSet
- Persistent Volume Claims (PVC) for data persistence
- Secrets securely synchronized from AWS Secrets Manager

---

## 🏗️ Terraform Architecture

```text
Terraform
    │
    ├── Amazon EKS Cluster
    ├── Managed Node Group
    ├── GitHub OIDC Provider
    ├── IAM Roles & Policies
    ├── AWS Load Balancer Controller
    ├── External Secrets Operator
    └── AWS Secrets Manager Integration
```

---

## 📸 Screenshots


Amazon EKS Cluster
<img width="1917" height="1080" alt="Screenshot (29)" src="https://github.com/user-attachments/assets/58ea6181-53f3-4003-804f-5284acc57a80" />
<img width="1920" height="1080" alt="Screenshot (30)" src="https://github.com/user-attachments/assets/3db863bd-8b37-4d52-a394-8f3064d657e7" />


GitHub OIDC Provider
<img width="1920" height="1080" alt="Screenshot (31)" src="https://github.com/user-attachments/assets/b0456903-cefd-429a-b39d-678f242869f0" />

AWS Load Balancer Controller
<img width="1920" height="1080" alt="Screenshot (32)" src="https://github.com/user-attachments/assets/1f1da855-d3db-469e-a9b0-4fa50851415e" />
<img width="1928" height="1078" alt="Screenshot (33)" src="https://github.com/user-attachments/assets/5d76afea-bbf3-41fe-9a18-cbfe2108b028" />

External Secrets Operator
<img width="1924" height="1078" alt="Screenshot (35)" src="https://github.com/user-attachments/assets/d1293096-919a-4681-bb67-2f259ff6eca4" />
<img width="1929" height="1080" alt="Screenshot (34)" src="https://github.com/user-attachments/assets/cacf87b3-63c2-41c1-aebd-01b7043ee4e5" />


AWS Secrets Manager
<img width="1933" height="1080" alt="Screenshot (36)" src="https://github.com/user-attachments/assets/98795019-3f30-42a0-9e9e-7351c673d8ce" />
  

---

# 🚀 CI/CD Pipeline

This project implements a **multi-environment CI/CD pipeline** using **GitHub Actions** to automate the complete software delivery lifecycle.

The deployment strategy consists of two independent environments:

- 🧪 QA Environment
- 🏭 Production Environment

This approach ensures that all changes are validated in the QA environment before being promoted to Production.

---

# 🧪 QA Deployment Pipeline

Whenever code is pushed to the **QA branch**, the QA workflow is triggered automatically.

### Pipeline Workflow

- Checkout the latest source code
- Build the Frontend and Backend Docker images
- Push images to Docker Hub
- Update Kubernetes manifests with the latest image tag
- Deploy the application to the **QA namespace**
- Verify Kubernetes rollout status

---

## QA Deployment Flow

```text
Developer
     │
     ▼
 Push to QA Branch
     │
     ▼
GitHub Actions
     │
     ▼
Build Docker Images
     │
     ▼
Push Images to Docker Hub
     │
     ▼
Update Kubernetes Manifests
     │
     ▼
Deploy to QA Namespace
     │
     ▼
Verify Rollout
     │
     ▼
QA Environment Ready
```

---

# 🏭 Production Deployment Pipeline

Once the application is successfully tested in QA, the code is merged into the **main branch**, triggering the Production pipeline.

Instead of rebuilding the application, the Production pipeline promotes the validated image from QA, ensuring consistency across environments.

### Pipeline Workflow

- Trigger on merge to the main branch
- Pull the approved Docker image
- Retag the image for Production
- Push the Production image to Docker Hub
- Update Production Kubernetes manifests
- Deploy to the **Production namespace**
- Verify deployment rollout

---

## Production Deployment Flow

```text
Merge QA → Main
        │
        ▼
GitHub Actions
        │
        ▼
Pull Approved QA Image
        │
        ▼
Retag Production Image
        │
        ▼
Push Production Image
        │
        ▼
Deploy to Production Namespace
        │
        ▼
Verify Rollout
        │
        ▼
Production Live
```

---

# 🐳 Docker Image Strategy

The application follows a simple image promotion strategy.

| Environment | Image |
|------------|-------|
| QA | Latest QA Image |
| Production | Promoted Production Image |

This ensures that the exact image tested in QA is deployed to Production.

---

# ☸ Kubernetes Namespaces

Separate namespaces are used to isolate environments.

| Namespace | Purpose |
|-----------|---------|
| `qa` | Testing & Validation |
| `prod` | Live Production Workloads |

---

# 📸 Screenshots

CICD for QA Environment

<img width="1920" height="1080" alt="Screenshot (53)" src="https://github.com/user-attachments/assets/b906eb46-38b8-4f05-8691-4a3ad6e4494e" />



# 🌐 Networking & Secure Application Access

The application is exposed securely over the internet using AWS networking and certificate management services.

## Amazon Route 53

Amazon Route 53 is used to manage the application's custom domain and DNS records.

**Features**
- Hosted Zone configuration
- DNS record management
- Custom domain routing
- Integration with AWS Application Load Balancer

---

## AWS Certificate Manager (ACM)

AWS Certificate Manager provides SSL/TLS certificates for secure HTTPS communication.

**Features**
- Free SSL/TLS certificates
- Automatic certificate renewal
- DNS validation using Route 53
- HTTPS enabled for the application

---

## AWS Load Balancer Controller

The AWS Load Balancer Controller automatically provisions an **Application Load Balancer (ALB)** based on Kubernetes Ingress resources.

**Features**
- Automatic ALB creation
- Ingress management
- Path-based routing
- HTTPS termination using ACM
- Internet-facing application access

---

# 🔑 Secrets Management

Application secrets are stored securely in **AWS Secrets Manager** and synchronized into Kubernetes using the **External Secrets Operator**.

### Workflow

```text
AWS Secrets Manager
          │
          ▼
External Secrets Operator
          │
          ▼
Kubernetes Secret
          │
          ▼
Application Pods
```

### Benefits

- No hardcoded credentials
- Centralized secret management
- Automatic synchronization
- Secure Kubernetes secret creation

---

# 🗄️ MySQL Database

The backend uses a **MySQL StatefulSet** running inside Kubernetes.

### Features

- StatefulSet deployment
- Persistent Volume Claims (PVC)
- Persistent data storage
- Credentials managed through AWS Secrets Manager
- Internal ClusterIP service for secure communication

---

# 📸 Screenshots



Route 53 Hosted Zone
<img width="3286" height="1080" alt="Screenshot (39)" src="https://github.com/user-attachments/assets/d9e35aa2-e010-45f3-b189-baf81cda07d9" />

ACM Certificate
<img width="1917" height="1080" alt="Screenshot (42)" src="https://github.com/user-attachments/assets/a0909eae-a6a3-491a-933b-9cf8b70ff39b" />

4. AWS Load Balancer
ALB Ingress
<img width="1924" height="1080" alt="Screenshot (43)" src="https://github.com/user-attachments/assets/ce6eff58-4c34-4d40-8dd5-b1a79d95685f" />

 Creating Pull Request
 <img width="1924" height="1080" alt="Screenshot (44)" src="https://github.com/user-attachments/assets/b314921c-7107-48bb-9f51-0a5e6f165e7a" />
 <img width="1920" height="1080" alt="Screenshot (52)" src="https://github.com/user-attachments/assets/261aebaf-a380-4ce2-8f5f-76d62ffda2dc" />
 <img width="1922" height="1080" alt="Screenshot (46)" src="https://github.com/user-attachments/assets/4d0981b2-9945-4789-82a6-1f80893a4169" />

 Merge QA to Main
<img width="1935" height="1077" alt="Screenshot (54)" src="https://github.com/user-attachments/assets/d35bfd04-c9a5-448d-83b4-1ca01f002300" />
 <img width="1922" height="1080" alt="Screenshot (56)" src="https://github.com/user-attachments/assets/9024928a-97c4-4ac0-892f-a69d826d23c7" />

CD pipeline Prod
<img width="1922" height="1080" alt="Screenshot (57)" src="https://github.com/user-attachments/assets/fecc2b88-749a-48cd-a52b-bd0ea008064e" />
<img width="1920" height="1067" alt="Screenshot (58)" src="https://github.com/user-attachments/assets/6fc8274a-dca4-4825-b51b-f96d42fb77b1" />
<img width="1926" height="1080" alt="Screenshot (60)" src="https://github.com/user-attachments/assets/f0165a9d-a6dc-4b02-97a3-40f0788fe66b" />

Application Accessible via Custom Domain
<img width="1926" height="1080" alt="Screenshot (60)" src="https://github.com/user-attachments/assets/249a1338-7e44-4856-9c8b-9e8db79f62e5" />
<img width="1927" height="1080" alt="Screenshot (61)" src="https://github.com/user-attachments/assets/748823b3-52fa-42cb-8bd0-b2bb8424fe19" />
<img width="1917" height="1080" alt="Screenshot (62)" src="https://github.com/user-attachments/assets/47f75ea4-6a7c-4e89-b265-ed02f3c2daf7" />
<img width="1922" height="1080" alt="Screenshot (64)" src="https://github.com/user-attachments/assets/ee67f4f1-d3ac-4511-91bd-b4450e94455d" />



# 📊 Observability Stack

To ensure complete visibility into the application's health and performance, this project implements a modern observability stack using the Grafana ecosystem.

The stack provides:

- 📈 Metrics Monitoring
- 📋 Centralized Log Aggregation
- 🔍 Distributed Tracing
- 📊 Interactive Dashboards
- 🚨 Real-time Cluster Monitoring

---

# 🏗️ Observability Architecture

```text
                 Kubernetes Cluster
                        │
      ┌─────────────────┼─────────────────┐
      │                 │                 │
      ▼                 ▼                 ▼
 Application       Kubernetes         System Logs
   Metrics            Logs             & Events
      │                 │                 │
      └──────────┬──────┴─────────────────┘
                 │
                 ▼
           Grafana Alloy
                 │
     ┌───────────┼────────────┐
     │           │            │
     ▼           ▼            ▼
 Prometheus     Loki        Tempo
     │           │            │
     └───────────┴────────────┘
                 │
                 ▼
             Grafana
        (Single Dashboard)
```

---

# 📈 Prometheus

Prometheus is responsible for collecting and storing metrics from the Kubernetes cluster and deployed applications.

### Metrics Collected

- Node Metrics
- Pod Metrics
- CPU Utilization
- Memory Utilization
- Network Usage
- Disk Usage
- Kubernetes Resource Health
- Application Metrics

### Benefits

- Real-time monitoring
- Time-series database
- Alerting support
- Kubernetes-native monitoring

---

# 📊 Grafana

Grafana provides a centralized dashboard for visualizing metrics, logs, and traces.

### Dashboards

- Kubernetes Cluster Dashboard
- Node Metrics Dashboard
- Pod Metrics Dashboard
- CPU & Memory Monitoring
- Application Health Dashboard
- Log Visualization
- Distributed Tracing

### Features

- Interactive dashboards
- Multiple data sources
- Unified observability
- Custom panels
- Real-time visualization

---

# 📋 Loki

Loki is used for centralized log aggregation from Kubernetes workloads.

### Logs Collected

- Application Logs
- Pod Logs
- Container Logs
- Kubernetes Events
- System Logs

### Benefits

- Centralized logging
- Efficient log storage
- Fast log searching
- Native Grafana integration

---

# 🔍 Tempo

Tempo enables distributed tracing across application services.

### Tracing Features

- End-to-end request tracing
- Service dependency visualization
- Latency analysis
- Performance troubleshooting
- Root cause analysis

---

# ⚙️ Grafana Alloy

Grafana Alloy acts as the telemetry collector within the cluster.

It collects and forwards:

- Metrics → Prometheus
- Logs → Loki
- Traces → Tempo

This provides a single, lightweight agent for collecting observability data across the Kubernetes environment.

---

# 🔄 Observability Data Flow

```text
Application
      │
      ▼
Grafana Alloy
      │
 ┌────┼─────────────┐
 │    │             │
 ▼    ▼             ▼
Metrics Logs      Traces
 │      │            │
 ▼      ▼            ▼
Prometheus Loki    Tempo
       │
       └──────┬───────────┐
              ▼
           Grafana
              │
              ▼
Unified Monitoring Dashboard
```

---

# 🚨 Monitoring Capabilities

The observability stack enables monitoring of:

- Kubernetes Cluster Health
- Node Resource Utilization
- Pod Status
- CPU Usage
- Memory Usage
- Network Traffic
- Application Availability
- Container Logs
- Request Traces
- Service Performance

---

# 📸 Screenshots

Deployed
<img width="1923" height="1080" alt="Screenshot (72)" src="https://github.com/user-attachments/assets/ae5a6839-ab43-4c05-9bb3-1f8c766e3e83" />
<img width="1922" height="1080" alt="Screenshot (65)" src="https://github.com/user-attachments/assets/15778f33-79db-4354-8d70-b45d9e03114d" />


Kubernetes Cluster Dashboard
<img width="1910" height="1080" alt="Screenshot (66)" src="https://github.com/user-attachments/assets/34ba5090-09fa-4833-bb96-816a0077c0e4" />
<img width="1922" height="1080" alt="Screenshot (67)" src="https://github.com/user-attachments/assets/5c910c3b-9165-4648-8238-5195480735cf" />

Prometheus
<img width="1928" height="1080" alt="Screenshot (68)" src="https://github.com/user-attachments/assets/eb47ac19-15e8-4fd7-836a-d4d42e0da5db" />

Complete Observability Dashboard
<img width="1922" height="1080" alt="Screenshot (71)" src="https://github.com/user-attachments/assets/fed7b22e-9c2f-436a-93dd-4d371fe9fe7e" />
<img width="1924" height="1080" alt="Screenshot (69)" src="https://github.com/user-attachments/assets/c561d388-3558-483a-8958-0c1dcae33761" />



---
