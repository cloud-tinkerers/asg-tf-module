// This file creates a launch template and then an autoscaling group that uses it

data "aws_ami" "al2023_ecs_latest" {
  most_recent = true
  name_regex = "al2023-ami-ecs-hvm*"
  filter {
    name = "architecture"
    values = ["arm64"]
  }
  owners = ["amazon"]
}

resource "aws_launch_template" "launch_template" {
  name       = "${var.client}-${var.app}-lt"
  image_id = data.aws_ami.al2023_ecs_latest.id
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    subnet_id                   = local.subnet_id
    security_groups             = [module.security_group.security_group_id]
  }
  placement {
    availability_zone = var.azs[0]
  }
  iam_instance_profile {
    name = "${aws_iam_instance_profile.ec2_host_profile.name}"
  }
  instance_type = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  metadata_options {
    http_endpoint               = "enabled"
    instance_metadata_tags      = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  user_data = filebase64("files/boot.sh")
  tags = local.default_tags
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                      = "${var.client}-${var.app}-${var.env}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  availability_zones        = [var.azs[0]]
  termination_policies      = ["OldestLaunchTemplate"]
  launch_template {
    id = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  tag {
    key = "Client"
    value = "${var.client}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.env}"
    propagate_at_launch = true
  }
  tag {
    key = "Application"
    value = "${var.app}"
    propagate_at_launch = true
  }
  tag {
    key = "Terraform"
    value = "true"
    propagate_at_launch = true
  }
  tag {
    key = "Name"
    value = "${var.client}-${var.app}-${var.env}-asg"
    propagate_at_launch = true
  }
}