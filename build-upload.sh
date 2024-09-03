#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ECR_REPO_NAME="transcribers"
COMMIT_HASH=$(git rev-parse origin/main)
DOCKER_IMAGE_NAME="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$COMMIT_HASH"

echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
echo "ECR_REPO_NAME=$ECR_REPO_NAME"
echo "LAST_COMMIT_HASH=$COMMIT_HASH"
echo "DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME"

# Ensure ECR repository exists
aws ecr describe-repositories --repository-names $ECR_REPO_NAME > /dev/null 2>&1 || \
aws ecr create-repository --repository-name $ECR_REPO_NAME

# Check if the image with the commit hash tag already exists
IMAGE_EXISTS=$(aws ecr describe-images --repository-name $ECR_REPO_NAME --image-ids imageTag=$COMMIT_HASH --query 'imageDetails | length(@)' --output text)

if [ "$IMAGE_EXISTS" -eq "1" ]; then
    echo
    echo "Image with tag $COMMIT_HASH already exists in ECR! Skipping build and push."
    exit 0
fi

# Get ECR login command and execute it
aws ecr get-login-password \
    --region ${AWS_DEFAULT_REGION} \
| docker login \
    --username AWS \
    --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Build and push Docker image

docker build -t $DOCKER_IMAGE_NAME -f ./Dockerfile .
docker push $DOCKER_IMAGE_NAME
