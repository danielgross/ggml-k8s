resource "aws_security_group" "efs" {
  name        = "llamacpp-efs"
  description = "Allow traffic"
  vpc_id      = aws_vpc.llamacpp-vpc.id

  ingress {
    description      = "nfs"
    from_port        = 2049
    to_port          = 2049
    protocol         = "TCP"
    cidr_blocks      = [aws_vpc.llamacpp-vpc.cidr_block]
  }
}

resource "aws_iam_policy" "node_efs_policy" {
  name        = "efs_csi_driver_role"
  path        = "/"
  description = "Policy for EFKS nodes to use EFS"

  policy = jsonencode({
    "Statement": [
        {
            "Action": [
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:DeleteAccessPoint",
                "ec2:DescribeAvailabilityZones"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": ""
        }
    ],
    "Version": "2012-10-17"
}
  )
}

resource "aws_efs_file_system" "kube" {
  tags = {
    Name = "llamacpp-efs"
  }
  creation_token = "eks-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "mount" {
    file_system_id = aws_efs_file_system.kube.id
    subnet_id = each.value
    for_each = {
      subnet_01 = aws_subnet.llamacpp-private-subnet-01.id
      subnet_02 = aws_subnet.llamacpp-private-subnet-02.id
    }
    security_groups = [aws_security_group.efs.id]
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy_attach" {
  role       = aws_iam_role.eks-node-group-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy" # or custom policy
}

resource "null_resource" "eks_addon" {
  depends_on = [
    aws_efs_mount_target.mount,
    aws_iam_role_policy_attachment.efs_csi_driver_policy_attach
  ]

  provisioner "local-exec" {
    command = <<EOT
      RETRIES=10
      for i in $(seq 1 $RETRIES); do
        eksctl get addon --cluster LlamaCppEKSCluster --name aws-efs-csi-driver && break || true
        if [ $i -eq $RETRIES ]; then
          echo "Failed to get addon after $RETRIES attempts, trying to create..."
          eksctl create addon --cluster LlamaCppEKSCluster --name aws-efs-csi-driver --version latest \
          --service-account-role-arn arn:aws:iam::351444663896:role/eks-cluster-LlamaCppEKSCluster --force && break
        fi
        echo "Attempt $i failed, retrying in 60 seconds..."
        sleep 60
      done
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }
}

output "efs_volume_handle" {
  value       = aws_efs_file_system.kube.id
}

resource "null_resource" "update_yaml" {
  depends_on = [aws_efs_file_system.kube]

  provisioner "local-exec" {
    command = <<EOT
      FILE="../../kubernetes/values.yaml"
      if [ ! -f "$FILE" ]; then
        mkdir -p $(dirname "$FILE")
        echo "persistence:" > "$FILE"
        echo "  pvc:" >> "$FILE"
        echo "    volumeHandle: \"\"" >> "$FILE"
      fi
      yq e -i '.persistence.pvc.volumeHandle = "${aws_efs_file_system.kube.id}"' "$FILE"
    EOT
  }
}
