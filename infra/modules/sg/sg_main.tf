resource "aws_security_group" "alb_sg" {

  name   = "practice-slb-sg"
  vpc_id = var.vpc_id
  tags   = { Project = "ecs-practice" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "alb_all_out" {

  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1

}

resource "aws_security_group" "ecs_task_sg" {

  name   = "practice-ecs-task-sg"
  vpc_id = var.vpc_id
  tags   = { Project = "ecs-practice" }

}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs_task_sg.id
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = var.ecs_task_port
  to_port                      = var.ecs_task_port
  ip_protocol                  = "tcp"

}

resource "aws_vpc_security_group_egress_rule" "ecs_all_out" {
  security_group_id = aws_security_group.ecs_task_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
