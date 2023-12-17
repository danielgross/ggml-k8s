# Get Account ID from CLI
account_id=$1

# Apply the ConfigMap directly without creating a YAML file
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::${account_id}:root
      username: root
      groups:
        - system:masters
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::${account_id}:role/eks-node-group-role-LlamaCppEKSCluster
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      - system:node-proxier
      rolearn: arn:aws:iam::${account_id}:role/eks-fargate-profile
      username: system:node:{{SessionName}}
EOF
