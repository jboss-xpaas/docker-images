#!/bin/bash

IMAGE_NAME="redhat/xpaas-uberfire-cluster-controller"
IMAGE_TAG="6.1"

# Build the container image.
echo "Building the Docker container for $IMAGE_NAME:$IMAGE_TAG.."
docker build --rm -t $IMAGE_NAME:$IMAGE_TAG .
echo "Build done"

# Create the latest tag
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest