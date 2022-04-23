resource "aws_ecs_service" "dots" {
  name            = "dots-service"
  #cluster         = "arn:aws:ecs:us-east-1:977173093032:cluster/test-cluster"
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.dots.arn
  desired_count   = 2
  #iam_role        = ""
  launch_type     = "EC2"
  #force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "simple-app"
    container_port   = 5000
  }

  depends_on = [
    aws_lb.main
  ]
}

resource "aws_ecs_task_definition" "dots" {
  family = "dotstakehome"
  
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
      {
        name      = "simple-app"
        image     = "977173093032.dkr.ecr.us-east-1.amazonaws.com/playdotstakehome:v0.0.1"
        cpu       = 10
        memory    = 300
        essential = true
        
        portMappings = [
            {
                hostPort      = 0 # set to zero for dynamic port mapping 80
                protocol      = "tcp"
                containerPort = 5000
            }
        ]
        secrets = [
            {
                name      = "db_password"
                valueFrom = "db_password"
            }
        ]
      }
  ])
}

# resource "aws_ecs_task_set" {
#     service = ""
#     cluster = ""
#     task_definition = ""

#     load_balancer {
#        target_group_arn = ""
#        container_name   = ""
#        container_port   = ""
#     }
# }

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "allow_80"
  }

}

resource "aws_lb" "main" { 
    name               = "dots-lb"
    internal           = false 
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = [aws_subnet.dots_1a.id, aws_subnet.dots_1b.id]
    ip_address_type    = "ipv4"

    # Would turn on logs for real production stuff
    #access_logs {
    #}
}

# Create this, but nothing in it, since ECS
# automnatically registers and deregisters containers
# with the target group.
resource "aws_lb_target_group" "main" {
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP" #HTTPS
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = ""

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}