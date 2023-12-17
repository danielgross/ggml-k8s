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
EOF
