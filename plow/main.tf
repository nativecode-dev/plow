terraform {
  backend "s3" {
    bucket  = "nativecode"
    encrypt = true
    key     = "terraform/production.tfstate"
    region  = "us-east-1"
  }
}

provider "aws" {
  region = "${var.aws-region}"
}

module "eks-vpc" {
  source            = "./modules/vpc"
  aws-region        = "${var.aws-region}"
  cluster-name      = "${var.cluster-name}"
  vpc-cidr          = "${var.vpc-cidr}"
  vpc-public-cidrs  = "${var.vpc-public-cidrs}"
  vpc-private-cidrs = "${var.vpc-private-cidrs}"
}

module "eks-cluster" {
  source            = "./modules/eks"
  asg-desired       = "${var.asg-desired}"
  asg-max           = "${var.asg-max}"
  asg-min           = "${var.asg-min}"
  cluster-name      = "${var.cluster-name}"
  instance-type     = "${var.instance-type}"
  vpc-id            = "${module.eks-vpc.vpc_id}"
  vpc-public-cidrs  = "${module.eks-vpc.public_subnets}"
  vpc-private-cidrs = "${module.eks-vpc.private_subnets}"
}
