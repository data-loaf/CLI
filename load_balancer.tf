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

resource "aws_security_group" "loaf_sg_lb" {
  name        = "loaf_sg_lb"
  description = "Security group for Load Balancer"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loaf_sg_lb.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "loaf_listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loaf_tg.arn
  }
}

resource "aws_lb_target_group" "loaf_tg" {
  name     = "dataloaf-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id

  health_check {
    enabled           = true
    healthy_threshold = 3
    matcher           = 200
    path              = "/health"
    protocol          = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment_a" {
  target_group_arn = aws_lb_target_group.loaf_tg.arn
  target_id        = aws_instance.loaf_app.id
}

# ********************************* #
# * ACM *                           #
# ********************************* #
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_dns" {
  for_each = {
    for robo in aws_acm_certificate.certificate.domain_validation_options : robo.domain_name => {
      name   = robo.resource_record_name
      record = robo.resource_record_value
      type   = robo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "certificate" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_dns : record.fqdn]
}

output "load_balancer_dns" {
  value = aws_lb.test.dns_name
}