# Docker Usage Guide for Background Removal

## Quick Start - Running Your Test in Docker

### Step 1: Add Your Test Image

First, copy your test image to the test_pics directory:

```bash
cd src/bg_removal

# If you have unknown.jpg on your local machine
cp /path/to/your/unknown.jpg test_pics/

# Or if you want to use a Farfetch product image
cp ../../data/images/SOME_PRODUCT_ID_index1.jpg test_pics/test_image.jpg
```

### Step 2: Start Docker Container

```bash
cd src/bg_removal
./docker-shell.sh
```

This will:
- Build the Docker image (first time only, ~2-5 minutes)
- Mount your directories into the container
- Start an interactive bash session

### Step 3: Run Your Test Inside Container

Once inside the container (you'll see a prompt like `root@xxxxx:/app#`):

```bash
# Your original command will work with the same paths!
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png

# Or run the full test
python test_simple.py
```

### Volume Mounts Explained

When you run `./docker-shell.sh`, these directories are mounted:

| Host Path (Your Machine) | Container Path | Purpose |
|--------------------------|----------------|---------|
| `src/bg_removal/test_pics/` | `/app/test_pics/` | Test images |
| `src/bg_removal/test_output/` | `/app/test_output/` | Results |
| `data/` | `/app/data/` | Farfetch images |

So inside the container:
- `/app/test_pics/unknown.jpg` → Your local `src/bg_removal/test_pics/unknown.jpg`
- `/app/test_output/unknown_result.png` → Your local `src/bg_removal/test_output/unknown_result.png`

---

## Complete Example

### On Your Local Machine:

```bash
# Navigate to bg_removal
cd src/bg_removal

# Add your test image
cp ~/Downloads/unknown.jpg test_pics/

# Start Docker
./docker-shell.sh
```

### Inside Docker Container:

```bash
# Same command as you used locally!
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png

# Output will appear in your local src/bg_removal/test_output/
```

### Back on Your Local Machine:

```bash
# Exit container (Ctrl+D or type 'exit')
exit

# View the result
open test_output/unknown_result.png
# or on Linux:
xdg-open test_output/unknown_result.png
```

---

## Common Docker Commands

### Start Container
```bash
cd src/bg_removal
./docker-shell.sh
```

### Inside Container - Test Commands

```bash
# Quick test with built-in test
python test_simple.py

# Single image (fast mode)
python background_removal_fast.py test_pics/unknown.jpg test_output/result.png

# Single image (full model)
python background_removal.py --input test_pics/unknown.jpg --output test_output/result.png

# Batch process Farfetch images
python batch_processor.py --input /app/data/images --output /app/data/images_nobg --workers 4

# Check GPU availability
python -c "import torch; print('GPU available:', torch.cuda.is_available())"
```

### Exit Container
```bash
exit
# or press Ctrl+D
```

---

## Processing Farfetch Images in Docker

### Single Farfetch Image:

```bash
# Start container
./docker-shell.sh

# Inside container
python background_removal_fast.py \
    /app/data/images/12345678_index1.jpg \
    /app/data/images_nobg/12345678_nobg.png
```

### Batch Process All Farfetch Images:

```bash
# Start container
./docker-shell.sh

# Inside container
python batch_processor.py \
    --input /app/data/images \
    --output /app/data/images_nobg \
    --workers 4 \
    --format png
```

Results will appear in your local `data/images_nobg/` directory!

---

## GPU Support

### With GPU:

The `docker-shell.sh` script includes `--gpus all` flag, so if you have:
- NVIDIA GPU
- NVIDIA Docker runtime installed
- Proper drivers

GPU will be automatically used!

Check inside container:
```bash
python -c "import torch; print(torch.cuda.is_available())"
```

### Without GPU (CPU Only):

If you don't have GPU or get errors, modify `docker-shell.sh`:

```bash
# Remove this line:
    --gpus all \
```

Or use this alternative command:
```bash
docker run --rm -it \
    -v "$(pwd)/../../data:/app/data" \
    -v "$(pwd)/test_output:/app/test_output" \
    -v "$(pwd)/test_pics:/app/test_pics" \
    farfetch-bg-removal /bin/bash
```

---

## Troubleshooting

### Issue: `docker: Error response from daemon: could not select device driver`

**Cause:** GPU flag used but NVIDIA Docker runtime not available

**Fix:** Edit `docker-shell.sh` and remove `--gpus all` line

### Issue: Permission denied on output files

**Cause:** Docker creates files as root

**Fix:** 
```bash
# On your local machine
sudo chown -R $USER:$USER test_output/
```

### Issue: Image not found in container

**Cause:** File not in mounted directory

**Fix:** Make sure your image is in `test_pics/` before starting Docker

### Issue: Docker build fails

**Cause:** Network or dependency issues

**Fix:**
```bash
# Clean build
docker build --no-cache -t farfetch-bg-removal .
```

### Issue: Container exits immediately

**Cause:** Error in docker-shell.sh

**Fix:** Run manually:
```bash
docker run --rm -it farfetch-bg-removal /bin/bash
```

---

## File Persistence

### What Persists:
✅ Files in `test_output/` - saved to your local machine
✅ Files in `test_pics/` - already on your local machine
✅ Files in `/app/data/` - saved to your local machine

### What Doesn't Persist:
❌ Anything else in container (logs, temp files, etc.)
❌ Installed packages (use Dockerfile to add permanently)

---

## Advanced: Custom Docker Commands

### Run Single Command (No Interactive Shell):

```bash
docker run --rm \
    -v "$(pwd)/../../data:/app/data" \
    -v "$(pwd)/test_output:/app/test_output" \
    -v "$(pwd)/test_pics:/app/test_pics" \
    farfetch-bg-removal \
    python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

### Mount Additional Directories:

```bash
docker run --rm -it \
    --gpus all \
    -v "$(pwd)/../../data:/app/data" \
    -v "$(pwd)/test_output:/app/test_output" \
    -v "$(pwd)/test_pics:/app/test_pics" \
    -v "/path/to/more/images:/app/extra_images" \
    farfetch-bg-removal /bin/bash
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Start Docker | `./docker-shell.sh` |
| Run test | `python test_simple.py` |
| Process single image | `python background_removal_fast.py test_pics/IMG.jpg test_output/OUT.png` |
| Batch process | `python batch_processor.py --input /app/data/images --output /app/data/images_nobg` |
| Check GPU | `python -c "import torch; print(torch.cuda.is_available())"` |
| Exit container | `exit` or `Ctrl+D` |

---

## Summary

1. ✅ Add test image to `test_pics/`
2. ✅ Run `./docker-shell.sh`
3. ✅ Use same commands as local (paths stay the same!)
4. ✅ Results appear in your local `test_output/`

**Your original command works exactly the same in Docker!**

```bash
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

---

Last Updated: 2025-10-15
