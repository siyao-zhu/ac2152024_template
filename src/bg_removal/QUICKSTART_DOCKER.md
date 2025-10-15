# Quick Start: Running Your Test in Docker

## Your Original Command
```bash
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

## Running the Same Command in Docker

### Option 1: Automated Script (Easiest)

```bash
cd src/bg_removal

# Add your test image first
cp /path/to/your/unknown.jpg test_pics/

# Run the automated script
./RUN_DOCKER_TEST.sh
```

The script will:
1. Check for your test image
2. Ask if you have GPU
3. Build and start Docker
4. Give you instructions
5. Show results when done

---

### Option 2: Manual Steps (Step-by-Step)

#### Step 1: Add Your Test Image
```bash
cd src/bg_removal
cp /path/to/your/unknown.jpg test_pics/
```

#### Step 2: Start Docker Container
```bash
./docker-shell.sh
```

**First time:** Docker will build the image (~2-5 minutes)
**Subsequent runs:** Starts immediately

#### Step 3: Inside Container, Run Your Command
```bash
# You'll see a prompt like: root@abc123:/app#

# Your EXACT same command works!
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

#### Step 4: Exit and View Results
```bash
# Exit container
exit

# View result on your local machine
open test_output/unknown_result.png
# or on Linux:
xdg-open test_output/unknown_result.png
```

---

## Path Mapping (Important!)

When you run `./docker-shell.sh`, your directories are automatically mounted:

| Your Local Path | Inside Docker | 
|----------------|---------------|
| `src/bg_removal/test_pics/` | `/app/test_pics/` |
| `src/bg_removal/test_output/` | `/app/test_output/` |
| `data/` | `/app/data/` |

**This means:**
- Same paths work in Docker and locally!
- Files you create in Docker appear on your local machine
- No need to copy files in/out of container

---

## Complete Example

```bash
# On your local machine
cd src/bg_removal
cp ~/Downloads/unknown.jpg test_pics/
./docker-shell.sh

# ─────────────────────────────────────────
# Now inside Docker container
# ─────────────────────────────────────────

python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
# Output: ✓ Done! Saved to test_output/unknown_result.png

exit

# ─────────────────────────────────────────
# Back on local machine
# ─────────────────────────────────────────

ls test_output/
# unknown_result.png is here!

open test_output/unknown_result.png
```

---

## Other Useful Commands in Docker

### Run the built-in test:
```bash
python test_simple.py
```

### Process a Farfetch product image:
```bash
python background_removal_fast.py \
    /app/data/images/12345678_index1.jpg \
    test_output/product_result.png
```

### Batch process all Farfetch images:
```bash
python batch_processor.py \
    --input /app/data/images \
    --output /app/data/images_nobg \
    --workers 4
```

### Check if GPU is available:
```bash
python -c "import torch; print('GPU:', torch.cuda.is_available())"
```

---

## Troubleshooting

### No GPU / GPU Error?

Edit `docker-shell.sh` and remove the `--gpus all` line:

```bash
# Before:
docker run --rm -it \
    --gpus all \
    -v "$(pwd)/../../data:/app/data" \
    ...

# After:
docker run --rm -it \
    -v "$(pwd)/../../data:/app/data" \
    ...
```

Or use the automated script which asks about GPU.

### Can't find image?

Make sure your image is in `test_pics/` BEFORE starting Docker:
```bash
ls test_pics/unknown.jpg  # Should exist
./docker-shell.sh          # Then start Docker
```

### Permission errors on output?

```bash
sudo chown -R $USER:$USER test_output/
```

---

## Summary

**The beauty of Docker here:** Your command works EXACTLY the same!

```bash
# Local machine:
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png

# Docker container:
python background_removal_fast.py test_pics/unknown.jpg test_output/unknown_result.png
```

**No path changes needed!** The volume mounts handle everything.

---

## Need More Help?

- Full Docker guide: `DOCKER_USAGE.md`
- General usage: `README.md`
- Integration: `INTEGRATION_GUIDE.md`

---

**Ready?** Run: `./RUN_DOCKER_TEST.sh`
