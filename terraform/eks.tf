module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    disk_size = 30
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 3
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = var.eks_tags

}

data "aws_eks_cluster" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}
