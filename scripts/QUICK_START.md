# Quick Start Guide - Livestock Disease Detection Training

##  Quick Setup (5 minutes)

### 1. Install Dependencies
```bash
pip install -r scripts/requirements.txt
```

### 2. Test the Setup
```bash
python scripts/test_training.py
```

### 3. Start Training
```bash
python scripts/train_model.py
```

##  What You'll Get

- **Model**: `assets/models/livestock_disease_model.pth`
- **Training Curves**: `assets/models/training_curves.png`
- **5 Disease Categories**: Lumpy Skin, FMD, Mastitis, Healthy, Dermatitis

##  Troubleshooting

### Common Issues:

1. **"No data found"**
   - Check that `assets/unlabeled_data/` exists
   - Ensure you have the dataset folders

2. **CUDA/GPU Issues**
   - Training will automatically use CPU if GPU not available
   - For GPU training, install CUDA-compatible PyTorch

3. **Memory Issues**
   - Reduce `batch_size` in `train_model.py` (line 322)
   - Reduce `num_epochs` for faster testing

4. **Import Errors**
   - Run: `pip install -r scripts/requirements.txt`
   - Check Python version (3.8+ recommended)

##  Expected Results

- **Training Time**: 1-3 hours (CPU) / 30-60 minutes (GPU)
- **Target Accuracy**: >85%
- **Model Size**: ~50MB
- **Classes**: 5 disease categories

##  Next Steps

1. **Monitor Training**: Watch console output for progress
2. **Check Results**: View `training_curves.png` for performance
3. **Deploy Model**: Convert to TensorFlow Lite for Flutter app
4. **Test Model**: Use trained model for inference

##  Support

If you encounter issues:
1. Check the console output for error messages
2. Run `python scripts/test_training.py` to diagnose
3. Ensure all dependencies are installed correctly
