#!/bin/bash

# The name of the domain
DOMAIN_NAME=$1

# The name of the ingress in Kubernetes
INGRESS_NAME="local-ai"

# The name of the namespace in Kubernetes
NAMESPACE="default"

# Extract the Ingress Host's name
INGRESS_HOST=$(kubectl get ingress ${INGRESS_NAME} -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Extract the Hosted Zone ID using the AWS CLI
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name ${DOMAIN_NAME} --query 'HostedZones[0].Id' --output text | cut -d'/' -f3)

# Update Route 53 record
aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch '{
  "Comment": "Update CNAME Record",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "*.api.'${DOMAIN_NAME}'",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "'${INGRESS_HOST}'"
          }
        ]
      }
    }
  ]
}'
