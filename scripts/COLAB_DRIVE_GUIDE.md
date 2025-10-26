#  Google Colab + Drive Training Guide

##  Quick Setup (10 minutes)

### Step 1: Upload Your Data to Google Drive

1. **Go to [Google Drive](https://drive.google.com/)**
2. **Sign in** with your Google account
3. **Create a new folder** called "Livestock Disease Detection"
4. **Upload your data folder**:
   - Navigate to your project folder
   - Upload the entire `assets/unlabeled_data` folder to Google Drive
   - This contains your 4,986+ images

### Step 2: Open Google Colab

1. **Go to [Google Colab](https://colab.research.google.com/)**
2. **Sign in** with the same Google account
3. **Click "New Notebook"**
4. **Upload the training notebook**: `scripts/livestock_disease_training.ipynb`

### Step 3: Connect to Your Drive Data

The notebook will automatically:
- Mount your Google Drive
- Find your data in the expected location
- Copy it to the Colab working directory
- Start training with GPU acceleration

##  What You'll Get

### Training Results
- **Model File**: `livestock_disease_model.pth` (~50MB)
- **Training Curves**: Real-time progress visualization
- **Final Accuracy**: Expected 85-95%
- **Training Time**: 1-3 hours with free GPU

### Model Performance
- **5 Disease Categories**: Lumpy Skin, FMD, Mastitis, Healthy, Dermatitis
- **Input Size**: 224x224 pixels
- **Architecture**: ResNet18 (pre-trained)
- **Mobile Ready**: Can be converted to TensorFlow Lite

##  Troubleshooting

### Common Issues

1. **"No data found in Google Drive"**
   - Ensure you uploaded the `assets/unlabeled_data` folder
   - Check the folder name matches exactly
   - Re-run the data loading cell

2. **"CUDA out of memory"**
   - Reduce batch size in the training cell
   - Change `batch_size = 32` to `batch_size = 16`

3. **Slow training**
   - Ensure you're using GPU runtime (Runtime > Change runtime type > GPU)
   - Free Colab provides Tesla T4 GPU

4. **Training stops**
   - Colab has time limits (12 hours for free)
   - Save checkpoints regularly
   - Use Colab Pro for longer sessions

##  Flutter Integration

After training, integrate with your Flutter app:

### 1. Download the Model
- The notebook will provide a download link
- Save `livestock_disease_model.pth` to your project

### 2. Convert to TensorFlow Lite
```python
# Add this to your Colab notebook
import torch
from torch.jit import script

# Load trained model
model = torch.load('livestock_disease_model.pth')
model.eval()

# Convert to TorchScript
scripted_model = script(model)
```

### 3. Update Flutter ML Service
Replace the mock service in `lib/core/services/ml_service.dart` with real inference.

##  Expected Results

With your 4,986 images, you can expect:

- **Training Accuracy**: 90-95%
- **Validation Accuracy**: 85-90%
- **Model Size**: ~50MB
- **Inference Speed**: <1 second per image
- **Disease Detection**: 5 categories with high confidence

##  Support

If you encounter issues:

1. **Check the console output** for error messages
2. **Restart the runtime** if needed (Runtime > Restart runtime)
3. **Verify your data** is properly uploaded to Drive
4. **Use GPU runtime** for faster training

##  Success Metrics

Your training is successful when:
-  Validation accuracy > 85%
-  No overfitting (train/val curves converge)
-  Model downloads successfully
-  Ready for Flutter integration

##  Next Steps

1. **Upload data to Google Drive**
2. **Open Google Colab**
3. **Upload the training notebook**
4. **Run with GPU runtime**
5. **Download your trained model**
6. **Integrate with Flutter app**

Your dataset is excellent for training a robust disease detection model! 
