# Background Removal Module

Fast, reliable background removal for Farfetch product images. Works on CPU or GPU and integrates seamlessly with the Farfetch data pipeline.

---

## 📋 Overview

This module provides automated background removal for fashion product images extracted from the Farfetch dataset. It uses state-of-the-art deep learning models to create clean, transparent product images suitable for e-commerce applications.

---

## 🚀 Quick Start

### 1) Install Dependencies

```bash
cd src/bg_removal
pip install -r requirements.txt
```

### 2) Run Quick Test

```bash
python test_simple.py
```

This will download the model (first run only, ~2GB) and save test results to `test_output/`.

### 3) Process a Single Image

**Fast path (CPU-optimized):**
```bash
python background_removal_fast.py ../../data/images/12345678_index1.jpg output.png
```

**Full model with options:**
```bash
python background_removal.py --input ../../data/images/12345678_index1.jpg --output result.png
```

### 4) Batch Process All Product Images

```bash
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 4 \
    --format png
```

---

## 🐳 Docker Usage

### Build and Run Container

```bash
cd src/bg_removal
./docker-shell.sh
```

Once inside the container:

```bash
# Run tests
python test_simple.py

# Process images
python batch_processor.py --input /app/data/images --output /app/data/images_nobg --workers 4
```

---

## 📚 Usage Examples

### Single Image Processing

```python
from background_removal import BackgroundRemover

# Initialize
remover = BackgroundRemover(model_name="briaai/RMBG-1.4")

# Remove background
result = remover.remove_background("product_image.jpg")
result.save("product_nobg.png", "PNG")

# With mask
result, mask = remover.remove_background("product_image.jpg", return_mask=True)
```

### Batch Processing

```python
from batch_processor import BatchProcessor

# Initialize
processor = BatchProcessor(
    model_name="briaai/RMBG-1.4",
    max_workers=4,
    output_format="png"
)

# Process directory
stats = processor.process_directory(
    input_dir="../../data/images",
    output_dir="../../data/images_nobg",
    recursive=False,
    overwrite=False
)

# Print summary
processor.print_summary()
```

### Integration with Farfetch Pipeline

Process images after extraction:

```bash
# Step 1: Extract images (from datapipeline)
cd ../datapipeline
python extract_images.py

# Step 2: Remove backgrounds
cd ../bg_removal
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 4
```

---

## 🎯 Model Options

### Default: RMBG-1.4 (Recommended)
- **Speed:** Fast (2-5 seconds per image on CPU)
- **Quality:** Excellent for fashion products
- **Model:** `briaai/RMBG-1.4`

```bash
python background_removal.py --input img.jpg --output out.png --model briaai/RMBG-1.4
```

### Alternative: BiRefNet (High Quality)
- **Speed:** Slower (5-15 seconds per image on CPU)
- **Quality:** Best edge refinement for complex fabrics
- **Model:** `ZhengPeng7/BiRefNet`

```bash
python background_removal.py --input img.jpg --output out.png --model ZhengPeng7/BiRefNet
```

### Fast Mode: rembg (Fallback)
- **Speed:** Very fast (1-3 seconds per image on CPU)
- **Quality:** Good for quick testing
- **Usage:** `background_removal_fast.py`

---

## 📊 Command-Line Options

### background_removal.py

```bash
python background_removal.py [OPTIONS]

Options:
  --input PATH        Input image path (required)
  --output PATH       Output image path (required)
  --model NAME        Model name (default: briaai/RMBG-1.4)
  --batch             Enable batch processing mode
```

### batch_processor.py

```bash
python batch_processor.py [OPTIONS]

Options:
  --input DIR         Input directory with images (required)
  --output DIR        Output directory (required)
  --model NAME        Model name (default: briaai/RMBG-1.4)
  --workers N         Number of parallel workers (default: 4)
  --format FORMAT     Output format: png or webp (default: png)
  --recursive         Process subdirectories
  --overwrite         Overwrite existing files
  --quality-threshold FLOAT  Minimum quality (0-1)
```

---

## 💡 Tips for Best Results

### Image Quality
- Use images ≥512px on the short side
- Center the product in the frame
- Ensure good lighting and contrast
- Avoid heavy shadows on the background

### Performance Optimization

**CPU Usage:**
- Use `background_removal_fast.py` for quick processing
- Set `--workers 2-4` for batch processing
- Process images in smaller batches

**GPU Usage:**
- GPU is auto-detected if available
- Significantly faster (10-50x speedup)
- Can use `--workers 8-16` for batch processing

**Check GPU availability:**
```python
import torch
print(torch.cuda.is_available())
```

### Batch Processing Tips
- Start with `--workers 4` and adjust based on system performance
- Use `--format webp` for smaller file sizes
- Enable `--recursive` to process subdirectories
- Processing report saved automatically to `processing_report.json`

---

## 📁 Project Structure

```
src/bg_removal/
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Docker configuration
├── docker-shell.sh               # Docker startup script
├── background_removal.py         # Main module (full model)
├── background_removal_fast.py    # Fast CPU version
├── batch_processor.py            # Batch processing utility
├── test_simple.py                # Quick test script
├── test_output/                  # Test results directory
├── test_pics/                    # Sample test images
└── examples/                     # Usage examples
```

---

## 🔧 Troubleshooting

### Common Issues

**ModuleNotFoundError**
```bash
pip install -r requirements.txt
```

**CUDA out of memory**
```bash
# Force CPU usage
CUDA_VISIBLE_DEVICES="" python background_removal.py --input img.jpg --output out.png
```

**Slow first run**
- Model download/caching is normal (~2GB)
- Subsequent runs will be much faster

**Poor quality cutouts**
- Try alternative model: `--model ZhengPeng7/BiRefNet`
- Pre-process image: resize to ≤2048px on long edge
- Ensure image is in sRGB color space

**Low quality input images**
- Use `--quality-threshold 0.3` to skip low-quality images in batch mode

---

## 🔗 Integration with Milestone 2 Pipeline

This module integrates with the existing Farfetch data pipeline:

1. **Data Extraction** (`src/datapipeline/extract_images.py`)
   - Downloads product images from Farfetch dataset
   
2. **Background Removal** (`src/bg_removal/batch_processor.py`) ← **You are here**
   - Removes backgrounds from product images
   
3. **CV Preprocessing** (`src/datapipeline/preprocess_cv.py`)
   - Further image preprocessing for model training
   
4. **Model Training** (`src/models/train_model.py`)
   - Train models on processed images

---

## 📦 Output Format

- **Format:** PNG with alpha channel (transparency)
- **Naming:** `{original_name}_nobg.png`
- **Size:** Original dimensions preserved
- **Quality:** Lossless PNG or high-quality WebP

---

## 🤝 Contributing

This module is part of the AC215 Milestone 2 project. Improvements and bug fixes are welcome.

---

## 📄 License

For educational purposes only. Part of AC215 coursework.
