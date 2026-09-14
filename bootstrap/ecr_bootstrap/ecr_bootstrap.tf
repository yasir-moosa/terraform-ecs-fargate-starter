resource "aws_ecr_repository" "pratice_repo" {
  name         = var.ecr_name
  force_delete = true

  tags = {
    Project = "ecs-practice"

  }

}
