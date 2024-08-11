# asg-tf-module

This module is pretty specific to the use case of my own terraform, which utilises an EBS volume that mounts to the ASG host because I'm too cheap to use EFS and I don't need more instances for HA yet. As such this module is designed around being single AZ.

## Usage

The module requires a handful of variables for naming conventions and it also needs to know the ARN for my EBS so that it can create a relevant policy.

```
module "asg-tf-module" {
  source        = "git@github.com:cloud-tinkerers/asg-tf-module.git"
  vpc_id        = module.vpc.vpc_id
  client        = var.client
  region        = var.region
  app           = var.app
  env           = var.env
  azs           = ["eu-west-1a"]
  asg_min_size  = 1
  asg_max_size  = 1
  instance_type = "t4g.micro"
  volume_arn    = aws_ebs_volume.myvolume.arn
}
```