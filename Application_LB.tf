resource "aws_alb" "public-load-balancer" {
  name            = "public-load-balancer"
   security_groups = ["${aws_security_group.LB_SGS.id}"]

  subnets = [
    "${aws_subnet.ECS_Public1.id}",
    "${aws_subnet.ECS_Public2.id}",
  ]
}

resource "aws_alb_target_group" "public-ecs-target-group" {
  name     = "public-ecs-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.ECS.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
  }

  depends_on = [
    "aws_alb.public-load-balancer",
  ]

  tags {
    Name = "public-ecs-target-group"
  }
}

resource "aws_alb_listener" "public-alb-listener" {
  load_balancer_arn = "${aws_alb.public-load-balancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.public-ecs-target-group.arn}"
    type             = "forward"
  }
}
