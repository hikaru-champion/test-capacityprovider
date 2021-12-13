
resource "aws_codedeploy_app" "ecs_codedeploy_app" {
  compute_platform = "ECS"
  name             = "test-ecs-codedeploy"
}

resource "aws_codedeploy_deployment_group" "this" {
  depends_on = [aws_ecr_repository.nginx_image_repo,
    aws_ecs_cluster.test_ecs_cluster,
  ]

  app_name               = aws_codedeploy_app.ecs_codedeploy_app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "test-ecs-codedeploygroup"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      //action_on_timeout = "CONTINUE_DEPLOYMENT"
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 5
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.test_ecs_cluster.name
    service_name = aws_ecs_service.nginx_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
        aws_lb_listener.test_nginx_listener01.arn]
      }

      target_group {
        name = aws_lb_target_group.test_nginx_tg01.name
      }

      test_traffic_route {
        listener_arns = [
        aws_lb_listener.test_nginx_listener02.arn]
      }

      target_group {
        name = aws_lb_target_group.test_nginx_tg02.name
      }

    }

  }

}