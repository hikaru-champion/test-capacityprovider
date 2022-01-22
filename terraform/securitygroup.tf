###############################################
# SecurityGroup Configure
###############################################
resource "aws_security_group" "sg_test_ecs_instance" {
  name   = "sg_test_ecs_instance"
  vpc_id = aws_vpc.test_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_test_ecs_instance"
  }
}

resource "aws_security_group" "sg_test_ecs_service" {
  name   = "sg_test_ecs_service"
  vpc_id = aws_vpc.test_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_test_ecs_service"
  }
}

resource "aws_security_group_rule" "rule_sg_test_ecs_service01" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_test_alb.id
  security_group_id        = aws_security_group.sg_test_ecs_service.id
}

resource "aws_security_group_rule" "rule_sg_test_ecs_service02" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_test_alb.id
  security_group_id        = aws_security_group.sg_test_ecs_service.id
}


resource "aws_security_group" "sg_test_alb" {
  name   = "sg_test_alb"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8100
    to_port          = 8100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_test_ecs_service"
  }
}