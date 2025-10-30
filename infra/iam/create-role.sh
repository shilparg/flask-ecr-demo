#!/bin/bash

# === Configuration ===
ACCOUNT_ID="255945442255"
ROLE_NAME="GITHUB_OIDC_ROLE"
TRUST_POLICY_PATH="infra/iam/trust-policy.json"
REGION="ap-southeast-1"

# === Create IAM Role ===
echo "Creating IAM role: $ROLE_NAME"
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document "file://$TRUST_POLICY_PATH" \
  --region "$REGION"

# === Attach Policies ===
echo "Attaching ECR and ECS policies"
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# === Validate Role ===
echo "Validating role creation"
aws iam get-role --role-name "$ROLE_NAME" --region "$REGION"