# 🚀 Training Setup Guide - RTX 3050 GPU

## Target: Achieve >95% Accuracy on Livestock Disease Detection

This guide will help you train your model using your RTX 3050 GPU with all 4 datasets.

---

## 📋 Prerequisites

- Windows 10/11
- NVIDIA RTX 3050 GPU
- Python 3.8 or higher
- CUDA-capable PyTorch installation

---

## 🔧 Step 1: Install Dependencies

### Option A: Install PyTorch with CUDA (Recommended for RTX 3050)

```powershell
# For CUDA 11.8 (Recommended for RTX 3050)
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# For CUDA 12.1 (If you have newer CUDA drivers)
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### Option B: Install All Dependencies at Once

```powershell
# Navigate to project directory
cd "C:\School\CS project\Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection"

# Install PyTorch with CUDA
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install other dependencies
pip install -r requirements.txt
```

---

## ✅ Step 2: Verify GPU is Available

Run this command to check if PyTorch can see your RTX 3050:

```powershell
python -c "import torch; print('CUDA Available:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"
```

**Expected Output:**
```
CUDA Available: True
GPU: NVIDIA GeForce RTX 3050 Laptop GPU
```

If you see `False`, PyTorch was not installed with CUDA support. Reinstall using Option A above.

---

## 🧪 Step 3: Test Data Loading (Optional but Recommended)

Before starting the full training, test that all datasets load correctly:

```powershell
python scripts/test_data_loading.py
```

This will:
- Load images from all 4 datasets
- Show class distribution
- Verify no corrupted images
- Display sample statistics

---

## 🎯 Step 4: Start Training

### Full Training (50 epochs, ~2-3 hours on RTX 3050)

```powershell
python scripts/train_livestock_model.py
```

### What Happens During Training:

1. **Dataset Loading**: Loads all images from:
   - `lcaugmented` (Lumpy skin disease)
   - `hcaugmented` (Healthy cattle)
   - `cattle diseases.v2i.yolov11` (YOLO dataset)
   - `cattle diseases.v2i.multiclass` (Multiclass dataset)

2. **Training**: 
   - Uses EfficientNetV2-M architecture
   - Batch size: 24 (optimized for RTX 3050)
   - Heavy data augmentation for better accuracy
   - Automatic learning rate adjustment
   - Early stopping if no improvement

3. **Outputs** (saved to `training_results/`):
   - `best_model.pth` - Your trained model
   - `training_history.png` - Training curves
   - `confusion_matrix_test.png` - Performance matrix
   - `per_class_metrics.png` - Detailed metrics
   - `final_metrics.json` - Complete results
   - `training_log.csv` - Epoch-by-epoch log

---

## 📊 Step 5: Monitor Training Progress

During training, you'll see:

```
Epoch 1/50
----------------------------------------------------------------------
Epoch 1 - Training: 100%|████████████| [00:45<00:00]
  loss: 0.8234  acc: 67.45%

Validation: 100%|████████████| [00:12<00:00]

Epoch 1 Summary:
  Train Loss: 0.8234 | Train Acc: 67.45%
  Val Loss:   0.7123 | Val Acc:   72.34%
  ✓ NEW BEST MODEL SAVED! Validation Accuracy: 72.34%
```

---

## 🎯 Expected Results

### Timeline (RTX 3050):
- **Epoch duration**: ~2-3 minutes per epoch
- **Total training time**: 2-3 hours (50 epochs max)
- **Early stopping**: May finish sooner if target achieved

### Accuracy Progression:
- **Epoch 1-5**: 60-75%
- **Epoch 5-15**: 75-85%
- **Epoch 15-30**: 85-95%
- **Epoch 30+**: 95%+ (TARGET!)

---

## 🔍 Step 6: Check Results

After training completes, check your results:

```powershell
# View results directory
cd training_results
dir

# Open visualizations
start training_history.png
start confusion_matrix_test.png
start per_class_metrics.png

# Read metrics
type final_metrics.json
```

### Success Indicators:

✅ **Validation Accuracy** >= 95%
✅ **Test Accuracy** >= 95%
✅ **All classes** have F1-Score > 90%
✅ **Confusion matrix** shows high diagonal values

---

## 🔧 Troubleshooting

### Problem: "CUDA out of memory"

**Solution**: Reduce batch size in the script:
```python
BATCH_SIZE = 16  # Change from 24 to 16
```

### Problem: "CUDA not available"

**Solution**: Reinstall PyTorch with CUDA:
```powershell
pip3 uninstall torch torchvision torchaudio
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

### Problem: Training is very slow

**Check**:
1. Is GPU being used? Look for "Device: cuda" in training output
2. Is batch size too small? Default is 24 for RTX 3050
3. Are num_workers set correctly? Default is 4

### Problem: Accuracy not reaching 95%

**Solutions**:
1. Increase epochs (change `NUM_EPOCHS = 50` to `NUM_EPOCHS = 100`)
2. The model uses early stopping, so it might need more patience
3. Try different learning rate: `INITIAL_LR = 0.0001`

---

## 📈 Optimizing for Higher Accuracy

If you want to push accuracy even higher:

### 1. Increase Image Size
```python
IMG_SIZE = 320  # Change from 288 to 320
BATCH_SIZE = 16  # Reduce batch size to fit in memory
```

### 2. More Epochs
```python
NUM_EPOCHS = 100
early_stop_patience = 25
```

### 3. Fine-tune on Best Model
After first training completes, train for more epochs:
```python
# Load best model and continue training
checkpoint = torch.load('training_results/best_model.pth')
model.load_state_dict(checkpoint['model_state_dict'])
optimizer.load_state_dict(checkpoint['optimizer_state_dict'])
# Continue training...
```

---

## 📁 Project Structure

```
Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection/
├── assets/
│   └── unlabeled_data/
│       ├── lcaugmented/          # Lumpy skin images
│       ├── hcaugmented/          # Healthy cattle images
│       ├── cattle diseases.v2i.yolov11/
│       └── cattle diseases.v2i.multiclass/
├── scripts/
│   ├── train_livestock_model.py  # Main training script
│   └── test_data_loading.py      # Data verification script
├── training_results/              # Created during training
│   ├── best_model.pth
│   ├── training_history.png
│   ├── confusion_matrix_test.png
│   ├── per_class_metrics.png
│   ├── final_metrics.json
│   └── training_log.csv
├── requirements.txt
└── TRAINING_SETUP_GUIDE.md       # This file
```

---

## 🎉 Quick Start (TL;DR)

```powershell
# 1. Install dependencies
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install -r requirements.txt

# 2. Verify GPU
python -c "import torch; print(torch.cuda.is_available())"

# 3. Train!
python scripts/train_livestock_model.py

# 4. Check results (after ~2-3 hours)
cd training_results
start training_history.png
```

---

## 📞 Need Help?

Common issues and solutions are in the Troubleshooting section above.

**Training Specs:**
- GPU: RTX 3050 (4GB VRAM)
- Batch Size: 24
- Image Size: 288x288
- Model: EfficientNetV2-M
- Expected Time: 2-3 hours
- Target Accuracy: >95%

---

**Good luck with your training! 🚀**

