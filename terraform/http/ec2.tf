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
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.loaf_sg_ec2.id]

  user_data = <<-EOF
    #!/bin/bash

    cd ./home/ubuntu
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update -y
    sudo apt install -y docker-ce
    git clone https://github.com/data-loaf/backend-app.git
    git clone https://github.com/data-loaf/frontend-app.git
    curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
    sudo bash /tmp/nodesource_setup.sh
    sudo apt install -y nodejs
    cd frontend-app
    sudo npm install
    sudo npm run build
    sudo cp -r ./dist ../backend-app
    cd ../backend-app
    sudo systemctl start docker
    echo "REDSHIFT_CONN_STRING=postgresql://${aws_redshift_cluster.redshift_cluster.master_username}:${aws_redshift_cluster.redshift_cluster.master_password}@${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}" >> .env
    sudo docker build -t backend-app:loaf .
    sudo apt install -y docker-compose
    sudo docker compose --env-file .env up -d
  EOF

  tags = {
    Name = "loaf_application"
  }
}

output "ec2_url" {
  value = aws_instance.loaf_app.public_dns
}
