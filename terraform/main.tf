terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "ap-south-1"
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = "devsecops-demo-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "devsecops-demo-eks"
  cluster_version = "1.30"
  subnets         = ["subnet-subnet-09fd738e21a8af806", "subnet-06412a02770cabacd"] # use your default VPC subnets
  vpc_id          = "vpc-055ba3bf4cbb25217"                        # your default VPC
  manage_aws_auth = true
  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_desired_capacity = 1
    }
  ]
}

output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

