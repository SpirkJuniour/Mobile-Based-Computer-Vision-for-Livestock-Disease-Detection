#  Google Colab Training Setup

##  Quick Start (5 minutes)

### Step 1: Prepare Your Data
1. **Zip your data folder:**
   - Navigate to `assets/unlabeled_data/`
   - Select all folders inside
   - Create a zip file named `livestock_data.zip`

### Step 2: Open Google Colab
1. Go to [Google Colab](https://colab.research.google.com/)
2. Sign in with your Google account
3. Click "New Notebook"

### Step 3: Upload the Training Notebook
1. Download `scripts/livestock_disease_training.ipynb` from your project
2. In Colab, go to **File > Upload notebook**
3. Upload the notebook file

### Step 4: Upload Your Data
1. In the notebook, run the first few cells
2. When prompted, upload your `livestock_data.zip` file
3. The notebook will automatically extract and process your data

### Step 5: Start Training
1. Run all cells in sequence (Ctrl+Shift+Enter)
2. Training will start automatically
3. Monitor progress in real-time

##  What You'll Get

### Training Results
- **Model File**: `livestock_disease_model.pth` (~50MB)
- **Training Curves**: Visual progress charts
- **Final Accuracy**: Expected 85-95%
- **Training Time**: 1-3 hours with free GPU

### Model Performance
- **5 Disease Categories**: Lumpy Skin, FMD, Mastitis, Healthy, Dermatitis
- **Input Size**: 224x224 pixels
- **Architecture**: ResNet18 (pre-trained)
- **Mobile Ready**: Can be converted to TensorFlow Lite

##  Troubleshooting

### Common Issues

1. **"No data found"**
   - Ensure you uploaded the zip file
   - Check that the zip contains the folder structure
   - Re-run the data extraction cell

2. **"CUDA out of memory"**
   - Reduce batch size in the training cell
   - Change `batch_size = 32` to `batch_size = 16`

3. **Slow training**
   - Ensure you're using GPU (check Runtime > Change runtime type > GPU)
   - Free Colab provides Tesla T4 GPU

4. **Training stops**
   - Colab has time limits (12 hours for free)
   - Save checkpoints regularly
   - Use Colab Pro for longer sessions

### Performance Tips

1. **Use GPU Runtime**
   - Go to Runtime > Change runtime type
   - Select "GPU" as hardware accelerator
   - This speeds up training 10x

2. **Save Progress**
   - Download the model periodically
   - Save to Google Drive for backup

3. **Monitor Training**
   - Watch the accuracy curves
   - Stop if overfitting occurs

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
3. **Verify your data** is properly uploaded
4. **Use GPU runtime** for faster training

##  Success Metrics

Your training is successful when:
-  Validation accuracy > 85%
-  No overfitting (train/val curves converge)
-  Model downloads successfully
-  Ready for Flutter integration

##  Next Steps

1. **Train the model** in Google Colab
2. **Download the results** to your local machine
3. **Integrate with Flutter** app
4. **Test with new images** from farmers
5. **Deploy to production** for real-world use

Your dataset is excellent for training a robust disease detection model! 
