
# handle secrets properly later

# resource "aws_ssm_parameter" "db_password" {
#   name  = "db_password"
#   type  = "SecureString"
#   value = "makearealsecretlater"
# }

# resource "aws_db_instance" "main" {
#   allocated_storage = 10
#   engine            = "mysql"
#   engine_version    = "5.7"
#   instance_class    = "db.t3.micro"
#   db_name           = "dots"
#   username          = "dots"
#   password          = aws_ssm_parameter.db_password.value
#   parameter_group_name = "default.mysql5.7"
#   skip_final_snapshot  = true
# }