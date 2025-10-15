#!/usr/bin/env python3
"""
Simple test script - Run this to test background removal!
Works with the Farfetch product images pipeline.
"""

import sys
import os

print("\n" + "="*60)
print("FARFETCH PRODUCT IMAGE - BACKGROUND REMOVAL TEST")
print("="*60 + "\n")

# Step 1: Check imports
print("Step 1/4: Checking dependencies...")
try:
    import torch
    from transformers import AutoModelForImageSegmentation
    from PIL import Image, ImageDraw
    import numpy as np
    print("  ✓ All dependencies installed\n")
except ImportError as e:
    print(f"  ✗ Missing dependency: {e}")
    print("\n  Run: pip install -r requirements.txt\n")
    sys.exit(1)

# Step 2: Check GPU
print("Step 2/4: Checking GPU...")
if torch.cuda.is_available():
    print(f"  ✓ GPU available: {torch.cuda.get_device_name(0)}")
else:
    print("  ⚠ No GPU, using CPU (slower but works)")
print()

# Step 3: Create test image
print("Step 3/4: Creating test image...")
os.makedirs('test_output', exist_ok=True)

# Create a simple test image (fashion product mockup)
img = Image.new('RGB', (800, 800), color='white')
draw = ImageDraw.Draw(img)

# Draw a simple "clothing item" shape
draw.rectangle([200, 150, 600, 650], fill='#4A90E2', outline='#2E5C8A', width=3)
draw.ellipse([250, 100, 550, 200], fill='#4A90E2', outline='#2E5C8A', width=3)
draw.text((300, 380), "PRODUCT", fill='white', font=None)

test_image_path = 'test_output/test_input.png'
img.save(test_image_path)
print(f"  ✓ Test image created: {test_image_path}\n")

# Step 4: Test background removal
print("Step 4/4: Testing background removal...")
print("  (First run will download model ~2GB, please wait...)\n")

try:
    from background_removal import BackgroundRemover
    
    # Initialize remover
    remover = BackgroundRemover(model_name="briaai/RMBG-1.4")
    
    # Remove background
    result = remover.remove_background(test_image_path)
    
    # Save result
    output_path = 'test_output/test_output.png'
    result.save(output_path, 'PNG')
    
    # Also save mask
    result_with_mask, mask = remover.remove_background(test_image_path, return_mask=True)
    mask.save('test_output/test_mask.png')
    
    print("\n" + "="*60)
    print("SUCCESS! ✓")
    print("="*60)
    print(f"\nResults saved to test_output/:")
    print(f"  • test_input.png   (original)")
    print(f"  • test_output.png  (background removed)")
    print(f"  • test_mask.png    (segmentation mask)")
    print("\nOpen these files to see the results!")
    print("\n" + "-"*60)
    print("NEXT STEPS:")
    print("-"*60)
    print("1. Test with actual Farfetch product image:")
    print("   python background_removal.py --input ../../data/images/PRODUCT_ID.jpg --output result.png")
    print("\n2. Process all Farfetch images in batch:")
    print("   python batch_processor.py --input ../../data/images --output ../../data/images_nobg --workers 4")
    print("\n3. Quick test with fast CPU version:")
    print("   python background_removal_fast.py ../../data/images/PRODUCT_ID.jpg output.png")
    print("\n")
    
except Exception as e:
    print(f"\n✗ Error: {e}")
    import traceback
    traceback.print_exc()
    print("\nIf you see a download error, check your internet connection.")
    sys.exit(1)
