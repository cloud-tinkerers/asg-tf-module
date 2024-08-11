// Policy to allow an EC2 instance to mount an EBS volume

data "aws_iam_policy_document" "ec2_sitedata_attach" {
  statement {
    sid = "AllowEC2SitedataAttach"
    actions = [
        "ec2:AttachVolume"
    ]
    resources = [
        "arn:aws:ec2:eu-west-1:${local.current_account_id}:instance/*",
		"${var.volume_arn}"
    ]
  }
}
resource "aws_iam_policy" "ec2_sitedata_attach" {
  name = "${var.client}-sitedata-attach"
  path = "/"
  description = "Allows an EC2 instance to mount the ${var.client} sitedata volume"
  policy = data.aws_iam_policy_document.ec2_sitedata_attach.json
}

// Policy to allow an EC2 instance to read values from the parameter store

data "aws_iam_policy_document" "parameter_store_access" {
  statement {
    sid = "AllowParameterStoreSecrets"
    actions = ["ssm:GetParameter",
               "ssm:GetParameters"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "parameter_store_access" {
  name = "${var.client}-ec2-parameter-store-access"
  path = "/"
  description = "Allow retrieval of values from the parameter store"
  policy = data.aws_iam_policy_document.parameter_store_access.json
}