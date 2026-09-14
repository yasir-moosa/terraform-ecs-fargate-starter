resource "aws_lb" "alb" {
  name               = "practice-alb"
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.subnet_ids
  internal           = false
  tags               = { Project = "ecs-practice" }

}


resource "aws_lb_target_group" "tg" {
  name_prefix = "ptg-"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id




  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = { Project = "ecs-practice" }
}


resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"




  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
