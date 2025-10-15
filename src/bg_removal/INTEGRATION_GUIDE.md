# Background Removal - Integration Guide

## Overview

This guide explains how the `bg_removal` module integrates with the Milestone 2 project structure and which files need to be modified when adding this functionality to your Farfetch data pipeline.

---

## Files Created/Modified

### New Files Created in `src/bg_removal/`

✅ **Core Module Files:**
- `background_removal.py` - Main background removal module with full model support
- `background_removal_fast.py` - Fast CPU-optimized version using rembg
- `batch_processor.py` - Batch processing utility with progress tracking
- `test_simple.py` - Quick test script to verify setup

✅ **Configuration & Deployment:**
- `requirements.txt` - Python dependencies for background removal
- `Dockerfile` - Container configuration for isolated execution
- `docker-shell.sh` - Docker startup script with volume mounts

✅ **Documentation:**
- `README.md` - Complete module documentation
- `INTEGRATION_GUIDE.md` - This file

✅ **Directory Structure:**
- `test_output/` - Directory for test results
- `test_pics/` - Directory for sample test images
- `examples/` - Directory for usage examples

### Modified Files

✅ **Main Project README** (`/workspace/README.md`)
- Added `bg_removal/` to project structure
- Added background removal as step 3 in data pipeline
- Added Docker container section for bg_removal
- Added complete pipeline workflow section

---

## Integration with Milestone 2 Structure

### Before Integration

```
src/
├── datapipeline/
│   ├── extract_images.py
│   ├── preprocess_cv.py
│   └── preprocess_rag.py
└── models/
    ├── train_model.py
    └── ...
```

### After Integration

```
src/
├── datapipeline/
│   ├── extract_images.py      # Step 1: Extract images
│   ├── preprocess_cv.py        # Step 3: CV preprocessing
│   └── preprocess_rag.py       # Step 4: RAG preparation
├── bg_removal/                  # Step 2: Remove backgrounds ← NEW
│   ├── background_removal.py
│   ├── batch_processor.py
│   └── ...
└── models/
    ├── train_model.py          # Step 5: Train models
    └── ...
```

---

## Data Flow

```
Farfetch JSON Dataset
        ↓
[datapipeline/extract_images.py]
        ↓
    data/images/
        ↓
[bg_removal/batch_processor.py] ← NEW MODULE
        ↓
 data/images_nobg/
        ↓
[datapipeline/preprocess_cv.py]
        ↓
   GCS Bucket (CV)
        ↓
[models/train_model.py]
```

---

## Usage Patterns

### Pattern 1: Manual Sequential Processing

```bash
# Extract images
cd src/datapipeline
python extract_images.py

# Remove backgrounds
cd ../bg_removal
python batch_processor.py --input ../../data/images --output ../../data/images_nobg

# Continue with CV preprocessing
cd ../datapipeline
./docker-shell.sh
```

### Pattern 2: Docker-Based Processing

```bash
# Extract images first (outside Docker)
cd src/datapipeline
python extract_images.py

# Background removal in Docker
cd ../bg_removal
./docker-shell.sh
# Inside container:
python batch_processor.py --input /app/data/images --output /app/data/images_nobg
```

### Pattern 3: Integrated Pipeline Script

Create a pipeline script that runs all steps:

```bash
#!/bin/bash
# pipeline.sh

echo "Step 1: Extract images..."
cd src/datapipeline
python extract_images.py

echo "Step 2: Remove backgrounds..."
cd ../bg_removal
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 4

echo "Step 3: Upload to GCS and preprocess..."
cd ../datapipeline
./docker-shell.sh
# (then run preprocessing inside container)
```

---

## Configuration Requirements

### Dependencies

The `bg_removal` module has its own `requirements.txt`:

```
torch>=2.0.0
transformers>=4.35.0
pillow>=10.0.0
opencv-python>=4.8.0
rembg>=2.0.50
tqdm>=4.66.0
```

These are **separate** from the main project dependencies to keep the module isolated.

### Docker Setup

The `docker-shell.sh` script mounts necessary volumes:

```bash
-v "$(pwd)/../../data:/app/data"           # Access to Farfetch images
-v "$(pwd)/test_output:/app/test_output"   # Test results
-v "$(pwd)/test_pics:/app/test_pics"       # Test images
```

---

## Testing the Integration

### Step 1: Verify Module Installation

```bash
cd src/bg_removal
pip install -r requirements.txt
python test_simple.py
```

Expected output:
- ✓ All dependencies installed
- ✓ GPU/CPU detection
- ✓ Test image created
- ✓ Background removal successful

### Step 2: Test with Real Product Image

```bash
# Ensure you have extracted at least one image
cd src/datapipeline
python extract_images.py  # (if not already done)

# Test background removal on one image
cd ../bg_removal
python background_removal_fast.py \
    ../../data/images/12345678_index1.jpg \
    test_output/product_test.png
```

### Step 3: Run Batch Processing

```bash
cd src/bg_removal
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 2  # Start with 2 workers for testing
```

Check output:
- Progress bar shows processing
- `data/images_nobg/` contains PNG files with transparent backgrounds
- `processing_report.json` created with statistics

---

## File Modifications Summary

### Files You MUST Create:
1. ✅ All files in `src/bg_removal/` (already created)

### Files You SHOULD Update:
1. ✅ `/workspace/README.md` - Updated with bg_removal documentation
2. ⚠️ `.gitignore` - Add background removal cache/output (recommended)

### Files You MAY Want to Create:
1. `pipeline.sh` - Automated pipeline script (optional)
2. `src/bg_removal/examples/` - Usage examples (optional)
3. Test images in `src/bg_removal/test_pics/` (optional)

---

## Recommended .gitignore Updates

Add these lines to your `.gitignore`:

```gitignore
# Background removal outputs
data/images_nobg/

# Background removal cache
src/bg_removal/.cache/
src/bg_removal/test_output/*.png
src/bg_removal/test_output/*.json

# Model cache
.cache/huggingface/
```

---

## Common Questions

### Q: Do I need to modify the datapipeline code?
**A:** No, the bg_removal module is completely independent and runs as a separate step.

### Q: Can I use this without Docker?
**A:** Yes! You can run all scripts directly with Python after installing requirements.

### Q: What if I don't have a GPU?
**A:** The module automatically detects and uses CPU. Use `background_removal_fast.py` for better CPU performance.

### Q: How do I integrate this with GCS/cloud storage?
**A:** Process images locally first, then upload the `data/images_nobg/` directory to GCS using the existing `preprocess_cv.py` workflow.

### Q: Can I run this in parallel with image extraction?
**A:** Not recommended. Run extraction first, then background removal. Or use a queue-based system for production.

---

## Next Steps

After integrating the bg_removal module:

1. ✅ Test the module with `test_simple.py`
2. ✅ Process a small batch of images
3. ✅ Verify output quality
4. ✅ Update your project documentation
5. ⚠️ Consider adding to CI/CD pipeline
6. ⚠️ Monitor performance and adjust worker count

---

## Troubleshooting

### Issue: Import errors
**Solution:** Make sure you're in the correct directory and have installed requirements
```bash
cd src/bg_removal
pip install -r requirements.txt
```

### Issue: Docker can't find images
**Solution:** Check volume mounts in `docker-shell.sh` and ensure data/images exists

### Issue: Out of memory
**Solution:** Reduce worker count or use CPU mode
```bash
python batch_processor.py --input ... --output ... --workers 2
```

### Issue: Poor quality results
**Solution:** Try the higher-quality model
```bash
python batch_processor.py --model ZhengPeng7/BiRefNet ...
```

---

## Support

For issues specific to background removal, see:
- `src/bg_removal/README.md` - Detailed module documentation
- Main project README - Integration information
- GitHub issues - Report bugs

---

**Last Updated:** 2025-10-15  
**Milestone:** 2  
**Module Version:** 1.0.0
