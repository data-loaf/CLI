# Create a security group
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
  ami                    = "ami-0f8b8f874036055b1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.loaf_sg_ec2.id]

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
    echo "REDSHIFT_CONN_STRING=postgresql://${aws_redshift_cluster.redshift_cluster.master_username}:${aws_redshift_cluster.redshift_cluster.master_password}@${aws_redshift_cluster.redshift_cluster.endpoint}/${aws_redshift_cluster.redshift_cluster.database_name}" > .env
    sudo docker build -t backend-app:loaf .
    sudo apt install docker-compose
    sudo docker compose --env-file .env up -d

  EOF

  tags = {
    Name = "loaf_application"
  }
}

/* resource "aws_acm_certificate" "cert" {
  domain_name       = aws_instance.loaf_dev.public_dns
  validation_method = "DNS"

  tags = {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "loaf_app_zone" {
  name         = aws_instance.loaf_dev.public_dns
  private_zone = false
}

resource "aws_route53_record" "loaf_app_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.loaf_app_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.loaf_app_record : record.fqdn]
}
*/
output "ec2_url" {
  value = aws_instance.loaf_app.public_dns
} 