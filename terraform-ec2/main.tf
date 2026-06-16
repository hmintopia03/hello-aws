terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "hello_sg" {
  name        = "hello-aws-terraform-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["222.110.134.166/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hello-aws-terraform-sg"
  }
}

resource "aws_instance" "hello" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.hello_sg.id
  ]

  tags = {
    Name = "hello-aws-terraform"
  }

  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -e

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    git

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| tee /etc/apt/keyrings/docker.asc > /dev/null

chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

cd /home/ubuntu
rm -rf hello-aws
git clone https://github.com/hmintopia03/aws.git hello-aws

cd hello-aws
docker compose up --build -d

chown -R ubuntu:ubuntu /home/ubuntu/hello-aws
EOF
}

resource "aws_eip" "hello_ip" {
  domain = "vpc"

  tags = {
    Name = "hello-aws-eip"
  }
}

resource "aws_eip_association" "hello_assoc" {
  instance_id   = aws_instance.hello.id
  allocation_id = aws_eip.hello_ip.id
}

