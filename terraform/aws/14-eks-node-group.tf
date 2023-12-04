variable "model_count" {
  description = "The number of models from the Helm chart"
  type        = number
  default     = 1
}

variable "ec2_instance_type" {
  description = "The type of EC2 instance to use for the EKS node group"
  type        = string
  default     = "c5.4xlarge"
}

variable "min_cluster_size" {
  description = "The minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "key_name" {
  description = "The name of the SSH key pair in AWS EC2"
  type        = string
  default     = "darioLocalKey"  # Replace with your actual key name if different
}


# resource "aws_launch_template" "eks_custom_ami" {
#   name_prefix   = "eks-custom-ami-"
#   image_id      = "ami-customamitoimplement" # Replace with your actual AMI ID for the auto-scaling group
#   instance_type = var.ec2_instance_type
#   key_name      = var.key_name
#   
#   block_device_mappings {
#     device_name = "/dev/xvda"
# 
#     ebs {
#       volume_size = 120
#       snapshot_id = "snap-customamitoimplement" # Replace with your actual snapshot ID for the auto-scaling group
#     }
#   }
# 
#   network_interfaces {
#     security_groups             = [aws_vpc.llamacpp-vpc.default_security_group_id]
#   }
# 
#   user_data = filebase64("./eks-user-data.sh")
# 
#   depends_on    = [
#     aws_iam_role_policy_attachment.eks-node-group-policy,
#     aws_iam_role_policy_attachment.eks-cni-policy,
#     aws_iam_role_policy_attachment.eks-registry-policy
#   ]
# 
#   tag_specifications {
#     resource_type = "instance"
# 
#     tags = {
#       Name = "eks-managed-node"
#     }
#   }
# }

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.LlamaCppEKSCluster.name
  node_group_name = "default-node-group"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids      = [
    aws_subnet.llamacpp-private-subnet-01.id,
    aws_subnet.llamacpp-private-subnet-02.id,
    aws_subnet.llamacpp-public-subnet-01.id,
    aws_subnet.llamacpp-public-subnet-02.id
  ]

  scaling_config {
    desired_size = var.min_cluster_size
    max_size     = 10
    min_size     = var.min_cluster_size
  }

  instance_types = [var.ec2_instance_type]
  disk_size      = 1440

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-group-policy,
    aws_iam_role_policy_attachment.eks-cni-policy,
    aws_iam_role_policy_attachment.eks-registry-policy
  ]

  # TODO: Implement autoscaling. 
  # tags = {
  #   "k8s.io/cluster-autoscaler/enabled" = "true"
  #   "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  # }

  # launch_template {
  #   id      = aws_launch_template.eks_custom_ami.id
  #   version = aws_launch_template.eks_custom_ami.latest_version
  # }

  # remote_access {
  #   ec2_ssh_key               = var.key_name   # Optional if you have a key pair you want to associate
  #   source_security_group_ids = [aws_security_group.eks.id]
  # }

  # Add tags if necessary
  # tags = {
  #   Environment = "production"
  # }

}

resource "aws_iam_role_policy_attachment" "node_efs_policy_attachment" {
  role       = aws_iam_role.eks-node-group-role.name
  policy_arn = aws_iam_policy.node_efs_policy.arn
  depends_on = [
    aws_iam_role.eks-node-group-role,
    aws_iam_policy.node_efs_policy
  ]
}
