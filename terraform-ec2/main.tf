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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 443
  to_port     = 443
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

resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "hello-aws-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cloudwatch_profile" {
  name = "hello-aws-ec2-cloudwatch-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

resource "aws_instance" "hello" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_cloudwatch_profile.name

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

resource "aws_security_group" "rds_sg" {
  name        = "hello-aws-rds-sg"
  description = "Allow PostgreSQL from EC2"

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.hello_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hello-aws-rds-sg"
  }
}

resource "aws_db_instance" "hello_db" {
  identifier        = "hello-aws-postgres"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "appdb"
  username = "app"
  password = "app12345678"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "hello-aws-postgres"
  }
}


resource "aws_s3_bucket" "uploads" {
  bucket = "hello-aws-hmintopia03-uploads"
}

resource "aws_iam_role_policy" "ec2_s3_upload_policy" {
  name = "hello-aws-ec2-s3-upload-policy"
  role = aws_iam_role.ec2_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.uploads.arn}/*"
      }
    ]
  })
}