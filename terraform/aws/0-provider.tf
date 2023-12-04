variable "aws_region" {
  default = "us-example-1"
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.LlamaCppEKSCluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.LlamaCppEKSCluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.LlamaCppEKSCluster.id]
      command     = "aws"
    }
  }
}

variable "cluster_name" {
  default = "LlamaCppEKSCluster"
}

variable "cluster_version" {
  default = "1.28"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}
