########################################
# ALB Configure
########################################
resource "aws_lb" "test_nginx_alb" {
  name               = "test-nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_test_alb.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]

  enable_deletion_protection = false

  /*   access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  } */

  tags = {
    Name = "test_nginx_alb"
  }
}

########################################
# Nginx01 Configuration
########################################
# 本番トラフィック用
resource "aws_lb_listener" "test_nginx01_listener01" {
  load_balancer_arn = aws_lb.test_nginx_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_nginx01_tg01.arn
  }

    lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_alb_listener_rule" "rule01" {
  listener_arn = aws_lb_listener.test_nginx01_listener01.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_nginx02_tg01.arn
  }

  condition {
    path_pattern {
        values = ["/target/*"]
    }
  }
}

resource "aws_lb_target_group" "test_nginx01_tg01" {
  name                 = "test-nginx01-tg01"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.test_vpc.id
  deregistration_delay = 300
  /*   health_check {
      enabled = true
      healthy_threshold = 3
      interval = 30
      matcher = 200
      path = "/healthcheck"
      port = 80
      protocol = "HTTP"
      timeout = 30
      unhealthy_threshold = 3
  } */
  load_balancing_algorithm_type = "least_outstanding_requests"
}

# テストトラフィック用
resource "aws_lb_listener" "test_nginx01_listener02" {
  load_balancer_arn = aws_lb.test_nginx_alb.arn
  port              = "8000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_nginx01_tg02.arn
  }

    lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_alb_listener_rule" "rule02" {
  listener_arn = aws_lb_listener.test_nginx01_listener02.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_nginx02_tg02.arn
  }

  condition {
    path_pattern {
        values = ["/target/*"]
    }
  }
}

resource "aws_lb_target_group" "test_nginx01_tg02" {
  name                 = "test-nginx01-tg02"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.test_vpc.id
  deregistration_delay = 300
  /*   health_check {
      enabled = true
      healthy_threshold = 3
      interval = 30
      matcher = 200
      path = "/healthcheck"
      port = 80
      protocol = "HTTP"
      timeout = 30
      unhealthy_threshold = 3
  } */
  load_balancing_algorithm_type = "least_outstanding_requests"
}

########################################
# Nginx02 Configuration
########################################
resource "aws_lb_target_group" "test_nginx02_tg01" {
  name                 = "test-nginx02-tg01"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.test_vpc.id
  deregistration_delay = 300
  /*   health_check {
      enabled = true
      healthy_threshold = 3
      interval = 30
      matcher = 200
      path = "/healthcheck"
      port = 80
      protocol = "HTTP"
      timeout = 30
      unhealthy_threshold = 3
  } */
  load_balancing_algorithm_type = "least_outstanding_requests"
}

resource "aws_lb_target_group" "test_nginx02_tg02" {
  name                 = "test-nginx02-tg02"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.test_vpc.id
  deregistration_delay = 300
  /*   health_check {
      enabled = true
      healthy_threshold = 3
      interval = 30
      matcher = 200
      path = "/healthcheck"
      port = 80
      protocol = "HTTP"
      timeout = 30
      unhealthy_threshold = 3
  } */
  load_balancing_algorithm_type = "least_outstanding_requests"
}