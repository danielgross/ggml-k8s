# resource "aws_eks_fargate_profile" "default" {
#   cluster_name           = aws_eks_cluster.LlamaCppEKSCluster.name
#   fargate_profile_name   = "default"
#   pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn
# 
#   # These subnets must have the following resource tag: 
#   # kubernetes.io/cluster/<CLUSTER_NAME>.
#   subnet_ids = [
#     aws_subnet.llamacpp-private-subnet-01.id,
#     aws_subnet.llamacpp-private-subnet-02.id
#   ]
# 
#   selector {
#     namespace = "default"
#   }
# }
