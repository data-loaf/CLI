resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet 1"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Default subnet 2"
  }
}

resource "aws_security_group" "loaf_sg_ec2" {
  name        = "loaf_sg_ec2"
  description = "Security group for EC2"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "loaf_app" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.loaf_sg_ec2.id]
  subnet_id              = aws_default_subnet.default_az1.id

  user_data = <<-EOF
    #!/bin/bash

    # This is a sample shell script
    cd ./home/ubuntu
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    sudo apt install -y docker-ce
    git clone https://github.com/Capstone2401/backend-app.git
    sudo systemctl start docker
    cd backend-app
    echo "REDSHIFT_CONN_STRING=postgresql://${aws_redshift_cluster.redshift_cluster.master_username}:${aws_redshift_cluster.redshift_cluster.master_password}@${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}" >> .env
    sudo docker build -t backend-app:loaf .
    sudo apt install docker-compose
    sudo docker compose --env-file .env up -d
  EOF

  tags = {
    Name = "loaf_application"
  }
}

output "ec2_url" {
  value = aws_instance.loaf_app.public_dns
}

