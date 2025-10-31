#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────
#  Environment Configuration
AWS_REGION="us-east-1"
REPO_NAME="flask-ecr-demo"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
SHA=$(git rev-parse HEAD)

# ─────────────────────────────────────────────────────────────
#  Authenticate with ECR
echo " Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$IMAGE_URI"

# ─────────────────────────────────────────────────────────────
#  Build Docker Image
echo " Building image with tags: latest and $SHA..."
docker build -t "$IMAGE_URI:latest" -t "$IMAGE_URI:$SHA" .

# ─────────────────────────────────────────────────────────────
#  Push Docker Image to ECR
echo " Pushing image to ECR..."
docker push "$IMAGE_URI:latest"
docker push "$IMAGE_URI:$SHA"

echo "✅ Deployment complete: $IMAGE_URI:$SHA"