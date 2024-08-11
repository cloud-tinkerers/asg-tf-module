variable "client" {
  type = string
  description = "Name of the client"
  
}

variable "region" {
  type = string
  description = "The AWS region being used."
}

variable "app" {
  type = string
  description = "The app in use"
}

variable "env" {
  type = string
  description = "The environment in use"
}

variable "vpc_id" {
  type = string
  description = "The VPC ID passed to the module"
}

variable "azs" {
  type = list(any)
  description = "A list of availability zones to use"
}

# variable "subnet" {
#   type = string
#   description = "The subnet to launch the autoscaling hosts in"
# }

variable "asg_min_size" {
  type = number
  description = "The minimum number of autoscaling hosts"
}

variable "asg_max_size" {
  type = number
  description = "The maximum number of autoscaling hosts"
}

variable "instance_type" {
  type = string
  description = "The instance type for the autoscaling group to use"
}

variable "volume_arn" {
  type = string
  description = "The ARN of the EBS volume to attach to the host"
}