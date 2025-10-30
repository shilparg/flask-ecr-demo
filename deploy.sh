#!/bin/bash
set -e

AWS_REGION="us-east-1"
REPO_NAME="flask-ecr-demo"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"
SHA=$(git rev-parse HEAD)

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $IMAGE_URI

echo "Building image..."
docker build -t $IMAGE_URI:latest -t $IMAGE_URI:$SHA .

echo "Pushing image..."
docker push $IMAGE_URI:latest
docker push $IMAGE_URI:$SHA