resource "aws_iam_role" "ecs" {
    name = "ecsInstanceRole"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = ""
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    })
    managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecsInstanceRole-profile"
  role = aws_iam_role.ecs.name
}


# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-parameters.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid    = ""
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "ecs-tasks.amazonaws.com"
            }
        }
        ]
    })
    managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]

    inline_policy {
        name = "parameter-store-ecs"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action   = ["ssm:GetParameters"]
                Effect   = "Allow"
                Resource = "*"
            }
        ]
        })
    }
}
