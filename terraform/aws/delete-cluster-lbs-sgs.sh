#!/bin/bash

# Get the VPC ID from AWS CLI
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='llamacpp-vpc']].VpcId | [0]" --output text)

# Get the ARNs of the load balancers in the VPC
LB_ARNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text)

# Delete load balancers
if [ -n "$LB_ARNS" ]; then
    echo "$LB_ARNS" | while read LB_ARN
    do
        echo "Deleting load balancer with ARN: $LB_ARN"
        aws elbv2 delete-load-balancer --load-balancer-arn "$LB_ARN"
    done
else
    echo "No load balancers found to delete for VPC_ID: $VPC_ID"
fi

# Get the security group IDs and names
SG_INFO=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='$VPC_ID' && GroupName!='default'].[GroupId,GroupName]" --output text)

# Delete security groups
if [ -n "$SG_INFO" ]; then
    echo "$SG_INFO" | while read SG_ID SG_NAME
    do
        echo "Deleting security group with ID: $SG_ID, Name: $SG_NAME"
        aws ec2 delete-security-group --group-id "$SG_ID"
    done
else
    echo "No security groups found to delete for VPC_ID: $VPC_ID"
fi
