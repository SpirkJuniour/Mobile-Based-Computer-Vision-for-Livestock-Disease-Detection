#  Livestock Disease Detection - Complete Training Guide

##  Your Dataset Summary
- **Total Images**: 3,824
- **Multiclass Dataset**: 834 images (567 train, 186 valid, 81 test)
- **YOLO Dataset**: 477 images (396 train, 81 test)
- **Augmented Datasets**: 2,513 images (1,500 healthy, 1,013 lumpy)
- **Quality**: Excellent for training!

##  Disease Categories
Your model will classify into 5 categories:
1. **Lumpy Skin Disease** (0)
2. **Foot and Mouth Disease** (1) 
3. **Mastitis** (2)
4. **Healthy** (3)
5. **Dermatitis** (4)

##  Training Options

### Option 1: Cloud Training (Recommended)
For the best results, train on cloud platforms:

#### Google Colab (Free)
1. Upload your data to Google Drive
2. Use the provided Colab notebook
3. Train with free GPU (Tesla T4)

#### Kaggle Notebooks (Free)
1. Upload dataset to Kaggle
2. Use GPU-enabled notebooks
3. Train with Tesla P100 GPU

### Option 2: Local Training
If you have a powerful local machine:

#### Requirements
- **GPU**: NVIDIA GPU with 8GB+ VRAM (RTX 3070/4070 or better)
- **RAM**: 16GB+ system RAM
- **Storage**: 10GB free space

#### Setup
```bash
# Install PyTorch with CUDA support
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install other dependencies
pip install pandas numpy pillow scikit-learn matplotlib seaborn opencv-python tqdm
```

##  Training Steps

### 1. Data Preparation
Your data is already well-organized! The training script will:
- Load images from all datasets
- Parse CSV labels from multiclass dataset
- Parse YOLO labels from txt files
- Assign labels to augmented datasets
- Split into train/validation/test sets

### 2. Model Architecture
- **Base Model**: ResNet18 (pre-trained on ImageNet)
- **Input Size**: 224x224 pixels
- **Output**: 5 disease categories
- **Regularization**: Dropout (0.5)

### 3. Training Configuration
- **Epochs**: 50-100
- **Batch Size**: 32
- **Learning Rate**: 0.001 (with decay)
- **Optimizer**: Adam
- **Loss Function**: CrossEntropyLoss

### 4. Data Augmentation
- Random horizontal flip
- Random rotation (±10°)
- Color jitter (brightness, contrast, saturation)
- Normalization

##  Expected Results

### Performance Targets
- **Training Accuracy**: 90-95%
- **Validation Accuracy**: 85-90%
- **Training Time**: 1-3 hours (GPU) / 6-12 hours (CPU)
- **Model Size**: ~50MB

### Output Files
- `livestock_disease_model.pth` - Trained model
- `training_curves.png` - Training progress
- `model_info.json` - Model metadata

##  Troubleshooting

### Common Issues

1. **CUDA Out of Memory**
   ```python
   # Reduce batch size in train_model.py
   batch_size = 16  # Instead of 32
   ```

2. **Slow Training**
   - Use GPU if available
   - Reduce image size to 128x128
   - Use fewer epochs for testing

3. **Poor Accuracy**
   - Increase training epochs
   - Check data quality
   - Adjust learning rate

4. **Class Imbalance**
   - Use weighted loss function
   - Apply data augmentation
   - Collect more data for minority classes

##  Flutter Integration

After training, integrate the model into your Flutter app:

### 1. Convert to TensorFlow Lite
```python
# Convert PyTorch model to TFLite
import torch
from torch.jit import script

# Load trained model
model = torch.load('livestock_disease_model.pth')
model.eval()

# Convert to TorchScript
scripted_model = script(model)

# Convert to TFLite (requires additional steps)
```

### 2. Update Flutter ML Service
Replace the mock ML service with real inference:

```dart
// In lib/core/services/ml_service.dart
Future<Map<String, dynamic>> predictDisease(File imageFile) async {
  // Load TensorFlow Lite model
  // Run inference
  // Return real predictions
}
```

##  Success Metrics

Your training is successful when:
-  Validation accuracy > 85%
-  No overfitting (train/val loss curves converge)
-  Model size < 100MB
-  Inference time < 1 second per image

##  Next Steps

1. **Choose Training Platform** (Cloud vs Local)
2. **Install Dependencies** (if training locally)
3. **Run Training Script** (`python scripts/train_model.py`)
4. **Monitor Progress** (watch console output)
5. **Evaluate Results** (check training curves)
6. **Deploy to Flutter** (integrate with app)

##  Expected Impact

With your 3,824 images, you can create a model that will:
- Help farmers detect diseases early
- Reduce livestock mortality
- Improve farm productivity
- Support veterinary decision-making

Your dataset is excellent for training a robust disease detection model! 
