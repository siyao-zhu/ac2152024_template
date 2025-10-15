#!/bin/bash

# Exit on error
set -e

# Docker image name
IMAGE_NAME="farfetch-bg-removal-arm64"

echo "============================================================"
echo "Building ARM64 Docker image for Apple Silicon Macs"
echo "============================================================"
echo ""

# Build the Docker image for ARM64
echo "Building Docker image: $IMAGE_NAME"
docker build --platform linux/arm64 -f Dockerfile -t $IMAGE_NAME .

# Run the Docker container
echo ""
echo "Starting Docker container..."
docker run --rm -it \
 --platform linux/arm64 \
 -v "$(pwd)/../../data:/app/data" \
 -v "$(pwd)/test_output:/app/test_output" \
 -v "$(pwd)/test_pics:/app/test_pics" \
 $IMAGE_NAME \
 /bin/bash
