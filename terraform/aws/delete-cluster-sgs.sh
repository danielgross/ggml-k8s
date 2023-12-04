#!/bin/bash

# Get the VPC ID from AWS CLI
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='llamacpp-vpc']].VpcId | [0]" --output text)

# Get the security group IDs and names
SG_INFO=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='$VPC_ID' && GroupName!='default'].[GroupId,GroupName]" --output text)

# Check if SG_INFO is not empty
if [ -n "$SG_INFO" ]; then
    # Loop through the security group IDs and delete each one
    echo "$SG_INFO" | while read SG_ID SG_NAME
    do
        echo "Deleting security group with ID: $SG_ID, Name: $SG_NAME"
        aws ec2 delete-security-group --group-id "$SG_ID"
    done
else
    echo "No security groups found to delete for VPC_ID: $VPC_ID"
fi
