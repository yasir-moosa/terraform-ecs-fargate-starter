variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_task_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "app_port" { type = number }
variable "aws_region" { type = string }
variable "ecr_repo_name" { type = string }
