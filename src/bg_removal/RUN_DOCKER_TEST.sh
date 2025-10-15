#!/bin/bash

# ============================================================
# Background Removal Docker Test Runner
# ============================================================
# This script helps you run the same test you did locally,
# but inside Docker container
# ============================================================

set -e

echo ""
echo "============================================================"
echo "STEP 1: Check for test image"
echo "============================================================"
echo ""

if [ -f "test_pics/unknown.jpg" ]; then
    echo "✓ Found: test_pics/unknown.jpg"
else
    echo "⚠ Test image not found!"
    echo ""
    echo "Please add your test image first:"
    echo "  cp /path/to/your/unknown.jpg test_pics/"
    echo ""
    echo "Or use a Farfetch product image:"
    echo "  cp ../../data/images/PRODUCT_ID_index1.jpg test_pics/unknown.jpg"
    echo ""
    read -p "Press Enter after you've added the image, or Ctrl+C to exit..."
fi

echo ""
echo "============================================================"
echo "STEP 2: Build and Start Docker Container"
echo "============================================================"
echo ""
echo "This will:"
echo "  1. Build the Docker image (first time only)"
echo "  2. Start an interactive container"
echo "  3. Mount your test_pics/ and test_output/ directories"
echo ""
echo "Starting in 3 seconds..."
sleep 3

# Check if user wants GPU or CPU
echo ""
read -p "Do you have NVIDIA GPU? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Running in CPU mode..."
    echo "Modifying docker command to remove GPU flag..."
    
    # Run without GPU
    docker build -t farfetch-bg-removal .
    
    echo ""
    echo "============================================================"
    echo "Container starting..."
    echo "============================================================"
    echo ""
    echo "Once inside, run:"
    echo "  python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png"
    echo ""
    
    docker run --rm -it \
        -v "$(pwd)/../../data:/app/data" \
        -v "$(pwd)/test_output:/app/test_output" \
        -v "$(pwd)/test_pics:/app/test_pics" \
        farfetch-bg-removal /bin/bash
else
    echo "Running with GPU support..."
    ./docker-shell.sh
fi

echo ""
echo "============================================================"
echo "Container exited"
echo "============================================================"
echo ""
echo "Check your results:"
echo "  ls -lh test_output/"
echo ""

if [ -f "test_output/unknown_result.png" ]; then
    echo "✓ Success! Result saved to: test_output/unknown_result.png"
    echo ""
    echo "View it with:"
    echo "  open test_output/unknown_result.png"
    echo "  # or on Linux:"
    echo "  xdg-open test_output/unknown_result.png"
else
    echo "⚠ Result file not found. Check for errors above."
fi

echo ""
