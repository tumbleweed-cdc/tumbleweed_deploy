#!/bin/bash

read -p "Enter the AWS Account ID: " AWS_ACCOUNT_ID
read -p "Enter the IAM Role Name: " ROLE_NAME
read -p "Enter the External ID: " EXTERNAL_ID

read -p "Enter the IP address to allow access (leave blank to auto-detect): " ACCESS_IP
if [ -z "$ACCESS_IP" ]; then
  ACCESS_IP=$(curl -s ifconfig.me)
  echo "Auto-detected public IP: $ACCESS_IP"
fi

# Check if jq is installed
# if ! command -v jq &> /dev/null; then
#   echo "jq is required but not installed. Please install jq and re-run the script."
#   exit 1
# fi

echo "Assuming role..."
ASSUME_ROLE_OUTPUT=$(aws sts assume-role \
  --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME" \
  --role-session-name "TumbleweedAppDeployment" \
  --external-id "$EXTERNAL_ID" \
  --output json)

if [ $? -ne 0 ]; then
  echo "Failed to assume role. Please check your input details and try again."
  exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo $ASSUME_ROLE_OUTPUT | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $ASSUME_ROLE_OUTPUT | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $ASSUME_ROLE_OUTPUT | jq -r '.Credentials.SessionToken')

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Failed to export temporary credentials. Exiting."
  exit 1
fi

echo "Temporary credentials obtained and exported successfully."

# Write IP address to terraform.tfvars file
echo "access_ip = \"$ACCESS_IP\"" > terraform.tfvars

echo "Running Terraform..."
terraform init
terraform apply -var "access_ip=$ACCESS_IP" -auto-approve

# Clear temporary credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

echo "Terraform deployment complete and credentials cleared!"
