#!/bin/bash

# Exit on error
set -e

# Docker image name
IMAGE_NAME="farfetch-bg-removal"

# Build the Docker image
echo "Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME .

# Run the Docker container
echo "Starting Docker container..."
docker run --rm -it \
    --gpus all \
    -v "$(pwd)/../../data:/app/data" \
    -v "$(pwd)/test_output:/app/test_output" \
    -v "$(pwd)/test_pics:/app/test_pics" \
    $IMAGE_NAME /bin/bash
