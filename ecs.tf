
resource "aws_ecs_cluster" "default" {
  name = "dotstakehome"

  # Add logging

  setting {
      name = "containerInsights"
      value = "enabled"
  }

}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
      name   = "name"
      values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["591542846629"]
}

resource "aws_launch_configuration" "main" {
  name_prefix = "dots-ecs-lc"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t2.micro"

  # Specify the created vpc key for debugging (to ssh onto instances)
  key_name = aws_key_pair.default.key_name

  # Allow port 80 inbound, all outbound
  security_groups = [aws_security_group.ecs_sg.id]

  # Attach the instance profile that allows for doing ECS things
  iam_instance_profile = aws_iam_instance_profile.ecs_profile.arn

  enable_monitoring = true

  user_data = <<-EOT
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.default.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;echo ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE=true >> /etc/ecs/ecs.config;
  EOT

  # Create a new LC before destroying the old one so the ASG 
  # is happy.
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "default" {
  name = "dotstakehome"

  vpc_zone_identifier = [aws_subnet.dots_1a.id, aws_subnet.dots_1b.id]

  # Would autoscale these for production
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  launch_configuration = aws_launch_configuration.main.name

  # Managed protection is enabled on the aws_ecs_capacity_provider, requiring
  # us to enable this protection.
  protect_from_scale_in = true

  # This tag gets automatically added when using aws_ecs_capacity_provider. 
  # Adding it here ensures Terraform does not remove it, while making sure
  # this tag is on all instances.
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "default" {
    name = "dotstakehome"

    auto_scaling_group_provider {
        auto_scaling_group_arn         = aws_autoscaling_group.default.arn 
        managed_termination_protection = "ENABLED"

        managed_scaling {
            status          = "ENABLED"
            target_capacity = "100"
        }
    }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
    cluster_name       = aws_ecs_cluster.default.name 
    capacity_providers = [aws_ecs_capacity_provider.default.name]

    default_capacity_provider_strategy {
      base = 2
      weight = 100
      capacity_provider = aws_ecs_capacity_provider.default.name
    }
}

