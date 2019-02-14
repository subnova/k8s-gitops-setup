variable "aws_region" {
  description = "The region in which the infrastructure will be deployed"
}

variable "environment" {
    description = "The name of the environment being deployed"
}

variable "availability_zones" {
    description = "The list of availability zones (with the region) to deploy to, e.g. eu-west-1a.  A maximum of 3 availability zones may be provided."
    type = "list"
}
