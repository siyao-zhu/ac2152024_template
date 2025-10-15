# Docker Command Reference Card

## Your Question: How to run this in Docker?

**Local command:**
```bash
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

**Docker command:** EXACTLY THE SAME! Just run it inside the container.

---

## Quick Answer (3 Steps)

```bash
# 1. Add your test image
cd src/bg_removal
cp /path/to/your/unknown.jpg test_pics/

# 2. Start Docker
./docker-shell.sh

# 3. Inside Docker, run your exact command
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

**Done!** Result appears in your local `test_output/` directory.

---

## Why Same Command Works?

The Docker container mounts your local directories:

```
Your Machine              Inside Docker
├── test_pics/       →    /app/test_pics/
├── test_output/     →    /app/test_output/
└── ../../data/      →    /app/data/
```

So `test_pics/unknown.jpg` in Docker **IS** your local file!

---

## Complete Example

```bash
$ cd src/bg_removal

$ cp ~/Downloads/unknown.jpg test_pics/

$ ./docker-shell.sh
Building Docker image: farfetch-bg-removal
[... build output ...]
Starting Docker container...
root@abc123:/app#                          ← You're now inside Docker

root@abc123:/app# python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
Processing test_pics/unknown.jpg...
(This should take 10-30 seconds on CPU)
✓ Done! Saved to test_output/unknown_result.png

root@abc123:/app# exit                     ← Exit Docker
exit

$ ls test_output/
unknown_result.png                         ← Your result!

$ open test_output/unknown_result.png      ← View it
```

---

## Other Useful Commands (Inside Docker)

```bash
# Run built-in test
python test_simple.py

# Process Farfetch product image  
python background_removal_fast.py /app/data/images/12345_index1.jpg test_output/result.png

# Batch process all Farfetch images
python batch_processor.py --input /app/data/images --output /app/data/images_nobg

# Full model (slower, better quality)
python background_removal.py --input test_pics/unknown.jpg --output test_output/result_hq.png

# Check GPU
python -c "import torch; print(torch.cuda.is_available())"
```

---

## Path Reference

| Description | Local Path | Docker Path |
|-------------|-----------|-------------|
| Your test images | `src/bg_removal/test_pics/` | `/app/test_pics/` |
| Output results | `src/bg_removal/test_output/` | `/app/test_output/` |
| Farfetch images | `data/images/` | `/app/data/images/` |
| Processed images | `data/images_nobg/` | `/app/data/images_nobg/` |
| Python scripts | `src/bg_removal/*.py` | `/app/*.py` |

---

## Automated Script (Even Easier!)

```bash
cd src/bg_removal
./RUN_DOCKER_TEST.sh
```

This script:
- ✅ Checks for your test image
- ✅ Asks about GPU (y/n)
- ✅ Builds and starts Docker
- ✅ Guides you through the process
- ✅ Shows results

---

## Troubleshooting Quick Fixes

### GPU Error?
```bash
# Edit docker-shell.sh, remove this line:
    --gpus all \
```

### Can't Find Image?
```bash
# Must copy BEFORE starting Docker
ls test_pics/unknown.jpg  # Check it exists
./docker-shell.sh         # Then start
```

### Permission Denied?
```bash
sudo chown -R $USER:$USER test_output/
```

### Want to Run Without Interactive Shell?
```bash
docker run --rm \
    -v "$(pwd)/test_pics:/app/test_pics" \
    -v "$(pwd)/test_output:/app/test_output" \
    farfetch-bg-removal \
    python background_removal_fast.py test_pics/unknown.jpg test_output/result.png
```

---

## Summary

### Local Machine
```bash
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

### Docker Container  
```bash
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

### They're the same! 🎉

The magic is in the volume mounts in `docker-shell.sh`:
```bash
-v "$(pwd)/test_pics:/app/test_pics"
-v "$(pwd)/test_output:/app/test_output"
```

---

**Ready to try?**
```bash
cd src/bg_removal && ./RUN_DOCKER_TEST.sh
```

or

```bash
cd src/bg_removal && ./docker-shell.sh
```
