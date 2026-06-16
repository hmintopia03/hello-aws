# Hello AWS

A cloud deployment project demonstrating how to deploy a containerized FastAPI application on AWS using Terraform, Docker, Amazon RDS, Amazon S3, and GitHub Actions.

## Architecture
```
Internet
  ↓
Nginx (EC2)
  ↓
FastAPI (Docker)
  ↙      ↘
RDS      S3

FastAPI
  ↓
IAM Role
  ↓
Amazon S3

GitHub Actions
  ↓
SSH Deploy
  ↓
EC2
```
Terraform provisions:
- EC2
- Elastic IP
- Security Group
- IAM Role
- RDS PostgreSQL
- S3 Bucket

## S3 Upload Demo

![S3 Upload Demo](s3-upload-demo.png)

## CI/CD

The application is automatically deployed to EC2 through GitHub Actions whenever changes are pushed to the `main` branch.

![GitHub Actions Deployment](github-actions-deploy.png)

## Features

* FastAPI REST API
* Amazon RDS PostgreSQL integration
* Amazon S3 file upload API
* Nginx reverse proxy
* Docker Compose deployment
* Infrastructure as Code with Terraform
* Elastic IP for stable public access
* IAM Role based AWS authentication
* Automated deployment with GitHub Actions

## Tech Stack

### Backend

* FastAPI
* Python 3.13

### Database

* Amazon RDS PostgreSQL 16

### Cloud Infrastructure

* AWS EC2
* Amazon RDS
* Amazon S3
* IAM
* Elastic IP
* Security Groups

### DevOps

* Docker
* Docker Compose
* Terraform
* GitHub Actions
* Nginx

## Local Development

```bash
docker compose up --build
```

Application:

```text
http://localhost:8000
```

## Infrastructure Provisioning

```bash
cd terraform-ec2

terraform init
terraform plan
terraform apply
```

Terraform provisions:

* EC2 Instance
* Security Group
* Elastic IP
* IAM Role and Instance Profile
* Amazon RDS PostgreSQL
* Amazon S3 Bucket

## CI/CD Pipeline

Every push to the `main` branch automatically:

1. Connects to EC2 via SSH
2. Pulls the latest source code
3. Rebuilds Docker images
4. Restarts application containers

## S3 File Upload

Upload a file:

```bash
curl -F "file=@README.md" http://<server-ip>/upload
```

Example response:

```json
{
  "bucket": "hello-aws-hmintopia03-uploads",
  "key": "uploads/example-file.txt"
}
```

Files are uploaded using EC2 IAM Role credentials.

No AWS access keys are stored in the application.

## Learning Goals

This project was created to practice:

* AWS fundamentals
* Infrastructure as Code
* Containerized deployment
* Reverse proxy configuration
* Managed database integration
* IAM Role authentication
* CI/CD automation
* Cloud networking basics
* AWS service integration

```
```
