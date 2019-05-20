variable "aws-region" {}
variable "cluster-name" {}
variable "vpc-cidr" {}

variable "vpc-public-cidrs" {
  type = "list"
}

variable "vpc-private-cidrs" {
  type = "list"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster-name}-eks-vpc"
  cidr = "${var.vpc-cidr}"

  azs             = "${var.availability_zones["${var.aws-region}"]}"
  private_subnets = "${var.vpc-private-cidrs}"
  public_subnets  = "${var.vpc-public-cidrs}"

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  tags = "${
    map(
     "Terraform","true",
     "Name", "${var.cluster-name}-eks-vpc",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}
