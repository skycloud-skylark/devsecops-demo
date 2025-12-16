# Specify provider
provider "aws" {
  region = "ap-south-1"  # Change to your region
}

# Create a basic VPC
resource "aws_vpc" "devsecops_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "devsecops-vpc" }
}

# Create subnets
resource "aws_subnet" "devsecops_subnet" {
  count             = 2
  vpc_id            = aws_vpc.devsecops_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.devsecops_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "devsecops-subnet-${count.index}" }
}

# Get availability zones
data "aws_availability_zones" "available" {}

# Create EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "devsecops-cluster"
  cluster_version = "1.27"
  subnets         = aws_subnet.devsecops_subnet[*].id
  vpc_id          = aws_vpc.devsecops_vpc.id

  node_groups = {
    devsecops_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }
}
