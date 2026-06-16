# Hello AWS

A simple cloud deployment project demonstrating how to deploy a FastAPI application on AWS EC2 with Amazon RDS PostgreSQL, Terraform, Docker, and GitHub Actions.

## Architecture


Internet
  ↓
Nginx (EC2)
  ↓
FastAPI (Docker)
  ↓
RDS PostgreSQL

GitHub Actions
  ↓
SSH Deploy
  ↓
EC2

Terraform
  ├─ EC2
  ├─ EIP
  ├─ Security Group
  ├─ IAM Role
  └─ RDS
```

## Features

* FastAPI backend
* Amazon RDS PostgreSQL
* Nginx reverse proxy
* Docker Compose deployment
* Infrastructure as Code with Terraform
* Elastic IP for stable public access
* IAM Role for AWS service access
* Automated deployment with GitHub Actions
* Security Group configuration for SSH and HTTP access


## Tech Stack

### Backend

* FastAPI
* Python 3.13

### Database

* PostgreSQL 16

### Infrastructure

* AWS EC2
* Elastic IP
* Security Groups
* Terraform

### DevOps

* Docker
* Docker Compose
* GitHub Actions

## Local Development

```bash
docker compose up --build
```

Application:

```text
http://localhost:8000
```

## Deployment

Infrastructure is managed using Terraform.

```bash
cd terraform-ec2

terraform init
terraform plan
terraform apply
```

Application deployment is automated through GitHub Actions.

Every push to the `main` branch triggers:

1. SSH connection to EC2
2. Pull latest source code
3. Rebuild Docker containers
4. Restart application

## Terraform Resources

* EC2 Instance
* Security Group
* Elastic IP
* IAM Role and Instance Profile
* Amazon RDS PostgreSQL
* User Data bootstrap script

## Learning Goals

This project was created to practice:

* AWS fundamentals
* Infrastructure as Code
* Containerized deployment
* Reverse proxy configuration
* CI/CD automation
* Managed database integration
* Cloud networking basics

```
```
