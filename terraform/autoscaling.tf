locals {
  user_data_config = <<EOF
#!/bin/bash
echo ECS_CLUSTER=test-ecs-cluster >> /etc/ecs/ecs.config;
EOF
}

data "aws_ssm_parameter" "ecs_ami_id" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

######################################################
# Launch Template Configuration
######################################################
resource "aws_launch_template" "test_ec2_lounch_template" {
  name = "test_ec2_lounch_template"

  disable_api_termination = true

  ebs_optimized = false

  iam_instance_profile {
    name = aws_iam_instance_profile.test_ecs.name
  }

  image_id = data.aws_ssm_parameter.ecs_ami_id.value

  instance_initiated_shutdown_behavior = "stop"

  instance_type = "m5.large"

  monitoring {
    enabled = false
  }

  vpc_security_group_ids = [aws_security_group.sg_test_ecs_instance.id]

  user_data = base64encode(local.user_data_config)
}
######################################################
# AutoScalingGroup Configuration
######################################################
resource "aws_autoscaling_group" "aws_autoscaling_group_1a" {
  name             = "test_aws_autoscaling_group_1a"
  max_size         = 3
  min_size         = 1
  desired_capacity = 1
  default_cooldown = 300

  launch_template {
    id      = aws_launch_template.test_ec2_lounch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier  = [aws_subnet.private_subnet_1a.id]
  termination_policies = ["NewestInstance"]

  protect_from_scale_in = true

  tags = [
    {
      key                 = "Name"
      value               = "test_ec2_az1a"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_group" "aws_autoscaling_group_1c" {
  name             = "test_aws_autoscaling_group_1c"
  max_size         = 3
  min_size         = 1
  desired_capacity = 1
  default_cooldown = 300

  launch_template {
    id      = aws_launch_template.test_ec2_lounch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier  = [aws_subnet.private_subnet_1c.id]
  termination_policies = ["NewestInstance"]

  protect_from_scale_in = true

  tags = [
    {
      key                 = "Name"
      value               = "test_ec2_az1c"
      propagate_at_launch = true
    }
  ]

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}