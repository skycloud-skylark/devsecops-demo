terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "ap-south-1"
}

################################
# ECR Repository
################################
resource "aws_ecr_repository" "app" {
  name = "devsecops-demo-app"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}

################################
# Networking (Default VPC)
################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

################################
# EKS Cluster
################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.6"

  cluster_name    = "devsecops-demo-eks"
  cluster_version = "1.29"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # REMOVE kms_key_aliases or kms_key_id entirely for AWS-managed key

  eks_managed_node_groups = {

    default = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      instance_types = ["t3.medium"]

      # 🔑 THIS LINE FIXES THE FAILURE
      enable_private_networking = true
    }
  }

  enable_cluster_creator_admin_permissions = true
}

################################
# Outputs
################################
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

