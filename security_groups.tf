// Security group to allow HTTPS traffic in, and all traffic out

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.client}-${var.app}-${var.env}"
  description = "Security Group for auto-scaling group."
  vpc_id      = var.vpc_id
  tags        = local.default_tags
}

resource "aws_security_group_rule" "https_access" {
  type              = "ingress"
  to_port           = 443
  protocol          = "tcp"
  from_port         = 443
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_id
}

// Add a rule to allow outbound internet access
resource "aws_security_group_rule" "internet_access" {
  type              = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = module.security_group.security_group_id
}