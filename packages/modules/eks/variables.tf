variable "vpc_id" {
  description = "The id of the VPC"
}

variable "environment" {
  description = "The environment name"
}

variable "aws_region" {
  description = "The AWS region to deploy into"
}

variable "availability_zones" {
  description = "The list of availability zones to use for deploying workers"
  type = "list"
}

variable "worker_subnets" {
  description = "The list of subnets names to use for deploying workers"
  type = "list"
}

variable "config_output_path" {
  description = "The location of the configuration output path (must end in a /)"
}

