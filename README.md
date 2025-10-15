# AC215 - Milestone 2 - Farfetch Dataset Image Extraction

**Team Members**
[Add your team member names here]

**Group Name**
[Add your group name here]

**Project**
In this project, we are building a fashion/product analysis system using the Farfetch dataset. Our pipeline extracts product images from Farfetch JSON datasets with multi-threading capabilities, processes them for computer vision tasks, and prepares data for RAG (Retrieval-Augmented Generation) models. The system is designed to handle large-scale fashion product data with robust error handling and efficient parallel processing.

---

## 📁 Project Structure

```
project/
├── README.md
├── data/                       # DO NOT UPLOAD DATA TO GITHUB
│   ├── images/                # Downloaded product images (output)
│   ├── men_data/              # Men's product dataset JSON files
│   └── women_data/            # Women's product dataset JSON files
├── notebooks/
│   └── eda.ipynb             # Exploratory Data Analysis
├── references/
├── reports/
│   └── Statement of Work_Sample.pdf
└── src/
    ├── datapipeline/
    │   ├── Dockerfile
    │   ├── Pipfile
    │   ├── Pipfile.lock
    │   ├── dataloader.py
    │   ├── docker-shell.sh
    │   ├── extract_images.py   # Multi-threaded image extraction
    │   ├── retry_failed.py     # Retry failed image downloads
    │   ├── preprocess_cv.py    # Computer vision preprocessing
    │   └── preprocess_rag.py   # RAG data preparation
    └── models/
        ├── Dockerfile
        ├── docker-shell.sh
        ├── infer_model.py
        ├── model_rag.py
        └── train_model.py
```

---

## 🚀 Milestone 2 Overview

In this milestone, we have developed the core components for data management, including versioning, extraction, and preprocessing pipelines for both computer vision and language models.

### Data Collection

We are working with product datasets from Farfetch, including:
- Men's fashion products with images and metadata
- Women's fashion products with images and metadata
- Product information including brands, descriptions, categories, prices, and multiple product images
- The datasets are stored as JSON files and processed to extract product images

---

## 📊 Data Pipeline

The complete data processing pipeline consists of three main stages:

1. **Image Extraction** - Download product images from Farfetch dataset
2. **Background Removal** - Remove backgrounds for clean product images  
3. **Preprocessing** - Prepare images for CV models and RAG system

---

### 1. Image Extraction (`src/datapipeline/extract_images.py`)

The primary script for extracting product images from Farfetch dataset JSON files.

**Features:**
- ✅ **Multi-file Processing** - Automatically processes all JSON files in the data directory
- ✅ **Multi-threaded Download** - 20 parallel workers for fast downloads
- ✅ **Real-time Progress Bar** - Beautiful progress tracking with tqdm
- ✅ **Smart Resume** - Skips already downloaded images
- ✅ **Error Logging** - Failed downloads saved to `failed_downloads.txt`
- ✅ **Index Filtering** - Extracts only index 1 and 2 images from product media

**Usage:**
```bash
# Install dependencies first
pip install requests tqdm

# Navigate to datapipeline directory
cd src/datapipeline

# Edit extract_images.py to set DATA_DIR (men_data or women_data)
# Then run the extractor
python3 extract_images.py
```

**Configuration in script:**
```python
DATA_DIR = '../../data/women_data'  # Change to men_data as needed
OUTPUT_DIR = '../../data/images'
MAX_WORKERS = 20                    # Number of parallel download threads
SPECIFIC_FILES = []                 # Optional: specify particular JSON files
```

**Output Example:**
```
============================================================
Farfetch Image Extractor
Multi-threaded with Progress Bars
============================================================

Scanning directory: ../../data/women_data
✓ Found 2 dataset file(s)

Loading datasets...
  Loading dataset_farfetch_2025-10-13.json...
  ✓ Loaded 500 products from dataset_farfetch_2025-10-13.json
  ✓ Found 1000 images from dataset_farfetch_2025-10-13.json

Total Summary:
  - Total products: 500
  - Total images (index 1 & 2): 1000

Starting parallel download:
  - Total images: 1000
  - Worker threads: 20
  - Output directory: ../../data/images

Downloading images: 100%|████████████| 1000/1000 [05:23<00:00, 3.09img/s]

Download Summary:
  ✓ Successfully downloaded: 850
  ✓ Already existed: 100
  ✗ Failed: 50

✅ Processing complete!
Images saved to: ../../data/images/
```

---

### 2. Retry Failed Downloads (`src/datapipeline/retry_failed.py`)

Retries downloading failed images with extended timeout and more aggressive retry strategy.

**Features:**
- Extended timeout: 60 seconds (3x longer than initial download)
- 5 retry attempts with progressive wait times (3s, 6s, 9s, 12s, 15s)
- Reads `failed_downloads.txt` and searches for URLs in dataset files
- Updates the failed downloads log with remaining failures

**Usage:**
```bash
cd src/datapipeline
python3 retry_failed.py
```

**Configuration:**
```python
DATA_DIR = '../../data/women_data'  # Can change to men_data as needed
OUTPUT_DIR = '../../data/images'
FAILED_LOG = '../../data/images/failed_downloads.txt'
MAX_WORKERS = 5  # Reduced workers for more stable connections
```

---

### 3. Background Removal (`src/bg_removal/`)

NEW in Milestone 2! Automated background removal for fashion product images using state-of-the-art deep learning models.

**Features:**
- ✅ **Multiple Models** - RMBG-1.4 (fast), BiRefNet (high quality), rembg (fastest)
- ✅ **GPU/CPU Support** - Auto-detects GPU, falls back to CPU
- ✅ **Batch Processing** - Multi-threaded processing with progress tracking
- ✅ **Docker Support** - Containerized execution environment
- ✅ **Integration Ready** - Seamlessly works with Farfetch image pipeline

**Quick Start:**
```bash
cd src/bg_removal

# Install dependencies
pip install -r requirements.txt

# Quick test
python test_simple.py

# Process single image (fast)
python background_removal_fast.py ../../data/images/12345678_index1.jpg output.png

# Batch process all images
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 4
```

**Docker Usage:**
```bash
cd src/bg_removal
./docker-shell.sh

# Inside container
python batch_processor.py --input /app/data/images --output /app/data/images_nobg --workers 4
```

**Output:** PNG images with transparent backgrounds saved to `../../data/images_nobg/`

See [src/bg_removal/README.md](src/bg_removal/README.md) for detailed documentation.

---

### 4. Computer Vision Preprocessing (`src/datapipeline/preprocess_cv.py`)

Handles preprocessing of images for computer vision tasks.

**Features:**
- Resizes images to configurable dimensions (default: 128x128)
- Enables faster iteration during model training
- Stores preprocessed dataset to Google Cloud Storage (GCS)

**Input:** Source and destination GCS locations, resizing parameters, required secrets (provided via Docker)

**Output:** Resized images stored in the specified GCS location

---

### 4. RAG Data Preparation (`src/datapipeline/preprocess_rag.py`)

Prepares data for the RAG (Retrieval-Augmented Generation) model.

**Features:**
- Performs text chunking of product descriptions
- Generates embeddings for product information
- Populates vector database (ChromaDB) for efficient retrieval

---

## 🔧 Dataset Structure

### Input JSON Format
Each product in the dataset follows this structure:

```json
{
  "brand": "Gucci",
  "title": "GG Marmont leather shoulder bag",
  "description": "Detailed product description...",
  "categories": ["Women", "Bags", "Shoulder Bags"],
  "medias": [
    {
      "type": "Image",
      "url": "https://cdn-images.farfetch-contents.com/.../image.jpg",
      "alt": "Product image",
      "index": 1
    },
    {
      "type": "Image",
      "url": "https://cdn-images.farfetch-contents.com/.../image.jpg",
      "alt": "Product image",
      "index": 2
    }
  ],
  "price": {
    "current": 225000,
    "currentFormatted": "$2,250"
  },
  "source": {
    "id": "12345678"
  }
}
```

### Output Image Files
Images are saved with the naming convention: `{product_id}_index{index}.jpg`

```
data/images/
├── 12345678_index1.jpg
├── 12345678_index2.jpg
├── 23456789_index1.jpg
├── 23456789_index2.jpg
└── ...
```

---

## 🐳 Docker Containers

### Data Pipeline Container

The data pipeline container handles all data extraction and preprocessing tasks.

**To run the container:**
```bash
cd src/datapipeline
./docker-shell.sh
```

**Features:**
- Image extraction from Farfetch datasets
- Computer vision preprocessing (image resizing, normalization)
- RAG data preparation (chunking, embedding, vector DB population)
- Integration with Google Cloud Storage

### Background Removal Container

The background removal container provides automated background removal for product images.

**To run the container:**
```bash
cd src/bg_removal
./docker-shell.sh
```

**Features:**
- State-of-the-art deep learning models (RMBG-1.4, BiRefNet)
- GPU acceleration (auto-detected)
- Batch processing with multi-threading
- Progress tracking and error handling
- Integration with Farfetch image pipeline

### Models Container

The models container contains scripts for model training, RAG pipeline, and inference.

**To run the container:**
```bash
cd src/models
./docker-shell.sh
```

**Components:**
- `train_model.py` - Model training scripts
- `model_rag.py` - RAG pipeline implementation
- `infer_model.py` - Model inference

---

## 📦 Dependencies

Core dependencies for the data pipeline:

- `requests` - HTTP requests and image downloads
- `tqdm` - Progress bars for download tracking
- `Pillow` - Image processing
- Additional dependencies in `Pipfile`

**Installation:**
```bash
pip install requests tqdm Pillow
```

---

## 📓 Notebooks & Reports

The `notebooks/` directory contains exploratory data analysis and visualizations:
- `eda.ipynb` - Exploratory Data Analysis of the Farfetch dataset

The `reports/` directory contains project documentation:
- `Statement of Work_Sample.pdf` - Project scope and requirements

---

## ⚙️ Configuration & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Set up data directories**
   ```bash
   mkdir -p data/men_data data/women_data data/images
   ```

3. **Add your dataset JSON files**
   - Place men's product JSON files in `data/men_data/`
   - Place women's product JSON files in `data/women_data/`

4. **Install dependencies**
   ```bash
   pip install requests tqdm
   ```

5. **Run the image extractor**
   ```bash
   cd src/datapipeline
   python3 extract_images.py
   ```

6. **(Optional) Remove backgrounds from product images**
   ```bash
   cd src/bg_removal
   pip install -r requirements.txt
   python batch_processor.py --input ../../data/images --output ../../data/images_nobg --workers 4
   ```

---

## 🔄 Complete Pipeline Workflow

Here's how to run the complete data processing pipeline:

```bash
# Step 1: Extract product images from Farfetch dataset
cd src/datapipeline
python extract_images.py
# Output: ../../data/images/

# Step 2: Remove backgrounds from product images
cd ../bg_removal
python batch_processor.py \
    --input ../../data/images \
    --output ../../data/images_nobg \
    --workers 4
# Output: ../../data/images_nobg/

# Step 3: Preprocess for CV models (in Docker)
cd ../datapipeline
./docker-shell.sh
python preprocess_cv.py
# Output: GCS bucket

# Step 4: Prepare RAG data (in Docker)
python preprocess_rag.py
# Output: ChromaDB vector database
```

---

## ⚠️ Important Notes

- ✅ For educational and research purposes only
- ✅ Please respect Farfetch's terms of service and robots.txt
- ✅ Use appropriate request delays to avoid overloading servers
- ✅ Do not commit large data files, trained models, or API keys to GitHub
- ✅ Use `.gitkeep` files to maintain directory structure

---

## 🤝 Contributing

This is an academic project for AC215. Issues and improvement suggestions are welcome.

---

## 📄 License

This project is for educational purposes only.

---

**Quick Start:** `cd src/datapipeline && python3 extract_images.py`
obots.txt
- ✅ Use appropriate request delays to avoid overloading servers
- ✅ Do not commit large data files, trained models, or API keys to GitHub
- ✅ Use `.gitkeep` files to maintain directory structure

---

## 🤝 Contributing

This is an academic project for AC215. Issues and improvement suggestions are welcome.

---

## 📄 License

This project is for educational purposes only.

---

**Quick Start:** `cd src/datapipeline && python3 extract_images.py`
