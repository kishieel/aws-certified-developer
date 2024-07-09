#!/usr/bin/env bash

if [ -z "$AWS_REGION" ]; then echo "Error: AWS_REGION is not set"; exit 1; fi
if [ -z "$AWS_ACCOUNT_ID" ]; then echo "Error: AWS_ACCOUNT_ID is not set"; exit 1; fi
if [ -z "$REPOSITORY_NAME" ]; then echo "Error: REPOSITORY_NAME is not set"; exit 1; fi

echo "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com

docker build -t "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$REPOSITORY_NAME":latest --file backend/Dockerfile backend
docker push "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$REPOSITORY_NAME":latest
