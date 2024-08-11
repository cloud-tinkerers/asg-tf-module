resource "aws_iam_role" "ec2_host_role" {
  name = "ec2-host-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "ssm_role_attachment" {
  role       = aws_iam_role.ec2_host_role.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

data "aws_iam_policy" "ec2_container_service" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "container_role_attachment" {
  role       = aws_iam_role.ec2_host_role.name
  policy_arn = data.aws_iam_policy.ec2_container_service.arn
}

resource "aws_iam_role_policy_attachment" "parameter_store_access" {
  role       = aws_iam_role.ec2_host_role.name
  policy_arn = aws_iam_policy.parameter_store_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_attach_sitedata_vol" {
  role       = aws_iam_role.ec2_host_role.name
  policy_arn = aws_iam_policy.ec2_sitedata_attach.arn
}

resource "aws_iam_instance_profile" "ec2_host_profile" {
  name = "ec2-host-profile"
  role = aws_iam_role.ec2_host_role.name
}