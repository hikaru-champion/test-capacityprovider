#############################################
# ECS Cluster Configure
#############################################
resource "aws_ecs_cluster" "test_ecs_cluster" {
  name               = "test-ecs-cluster"
  capacity_providers = [aws_ecs_capacity_provider.test-capacityprovider-az1a.name, aws_ecs_capacity_provider.test-capacityprovider-az1c.name]

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  depends_on = [aws_ecs_capacity_provider.test-capacityprovider-az1a, aws_ecs_capacity_provider.test-capacityprovider-az1c]

}

#############################################
# ECS Capacity Provider Configure
#############################################
resource "aws_ecs_capacity_provider" "test-capacityprovider-az1a" {
  name = "test-capacityprovider-az1a"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.aws_autoscaling_group_1a.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  depends_on = [aws_autoscaling_group.aws_autoscaling_group_1a]
}

resource "aws_ecs_capacity_provider" "test-capacityprovider-az1c" {
  name = "test-capacityprovider-az1c"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.aws_autoscaling_group_1c.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  depends_on = [aws_autoscaling_group.aws_autoscaling_group_1c]
}

#############################################
# ECS Task Definition Configure
#############################################
# nginx01
resource "aws_ecs_task_definition" "nginx01_task_definition" {
  family                   = "nginx01_task"
  execution_role_arn       = aws_iam_role.test_ecs_task_execution_role.arn
  ipc_mode                 = "none"
  network_mode             = "awsvpc"
  pid_mode                 = "task"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx01-container"
      image     = "${aws_ecr_repository.nginx01_image_repo.repository_url}:latest"
      cpu       = 128
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx01_service" {
  capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.test-capacityprovider-az1a.name
  }
  capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.test-capacityprovider-az1c.name
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  name            = "nginx01_service"
  cluster         = aws_ecs_cluster.test_ecs_cluster.id
  task_definition = aws_ecs_task_definition.nginx01_task_definition.arn
  desired_count   = 2
  #iam_role              = aws_iam_role.test_ecs_service_role.arn
  depends_on = [aws_iam_role.test_ecs_service_role]
  network_configuration {
    subnets          = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]
    security_groups  = [aws_security_group.sg_test_ecs_service.id]
    assign_public_ip = false
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.test_nginx01_tg01.arn
    container_name   = "nginx01-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition]
  }
}

# nginx02
resource "aws_ecs_task_definition" "nginx02_task_definition" {
  family                   = "nginx02_task"
  execution_role_arn       = aws_iam_role.test_ecs_task_execution_role.arn
  ipc_mode                 = "none"
  network_mode             = "awsvpc"
  pid_mode                 = "task"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx02-container"
      image     = "${aws_ecr_repository.nginx02_image_repo.repository_url}:latest"
      cpu       = 256
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx02_service" {
  capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.test-capacityprovider-az1a.name
  }
  capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.test-capacityprovider-az1c.name
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  name            = "nginx02_service"
  cluster         = aws_ecs_cluster.test_ecs_cluster.id
  task_definition = aws_ecs_task_definition.nginx02_task_definition.arn
  desired_count   = 2
  #iam_role              = aws_iam_role.test_ecs_service_role.arn
  depends_on = [aws_iam_role.test_ecs_service_role]
  network_configuration {
    subnets          = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1c.id]
    security_groups  = [aws_security_group.sg_test_ecs_service.id]
    assign_public_ip = false
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.test_nginx02_tg01.arn
    container_name   = "nginx02-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition]
  }
}