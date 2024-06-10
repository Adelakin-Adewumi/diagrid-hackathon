
provider "kubernetes" {
    host = data.aws_eks_cluster.eks-cluster.endpoint
    token = data.aws_eks_cluster_auth.eks-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "eks-cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "eks-cluster" {
  name = module.eks.cluster_name
}
# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.16"

  cluster_name                   = var.name
  cluster_version                = var.k8s_version
  cluster_endpoint_public_access = true
  
  vpc_id     = module.myapp-vpc.vpc_id
  subnet_ids = module.myapp-vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false
  
  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {}
  }
  
  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.micro"]
      min_size     = 2
      max_size     = 6
      desired_size = 3
    }
  }

  tags = var.tags
}
