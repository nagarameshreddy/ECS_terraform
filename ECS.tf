
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_ecs_cluster" "ecs1" {
  name = "test"
}

resource "aws_launch_configuration" "webserver-ecs-launch-configuration" {
  name                 = "webserver-ecs-launch-configuration"
  image_id             = "${data.aws_ami.ecs.id}"
  instance_type        = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.ecsroleprofile.id}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 30
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = ["${aws_security_group.LB_SGS.id}"]
  associate_public_ip_address = "true"
 # key_name                    = "new"

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.ecs1.id} >> /etc/ecs/ecs.config
EOF
}


resource "aws_autoscaling_group" "public-autoscaling-group" {
  name                 = "public-autoscaling-group"
  max_size             = "10"
  min_size             = "2"
  desired_capacity     = "2"
  vpc_zone_identifier  = ["${aws_subnet.ECS_Private1.id}", "${aws_subnet.ECS_Private2.id}"]
  launch_configuration = "${aws_launch_configuration.webserver-ecs-launch-configuration.name}"
  health_check_type    = "ELB"
}