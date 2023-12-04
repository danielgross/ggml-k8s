resource "aws_iam_role" "llamacpp-eks-cluster-role" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "llamacpp-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.llamacpp-eks-cluster-role.name
}

resource "aws_eks_cluster" "LlamaCppEKSCluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.llamacpp-eks-cluster-role.arn

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = [
      aws_subnet.llamacpp-private-subnet-01.id,
      aws_subnet.llamacpp-private-subnet-02.id,
      aws_subnet.llamacpp-public-subnet-01.id,
      aws_subnet.llamacpp-public-subnet-02.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.llamacpp-eks-cluster-policy]
}
