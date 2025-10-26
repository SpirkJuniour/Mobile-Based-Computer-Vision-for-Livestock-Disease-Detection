#!/usr/bin/env python3
"""
Start Training Script for Livestock Disease Detection

This script provides options for starting the training process.
"""

import os
import sys
import subprocess
from pathlib import Path

def check_python_version():
    """Check if Python version is compatible"""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print(" Python 3.8+ required. Current version:", f"{version.major}.{version.minor}")
        return False
    print(f" Python version: {version.major}.{version.minor}")
    return True

def check_data():
    """Check if data is available"""
    data_dir = "assets/unlabeled_data"
    if not os.path.exists(data_dir):
        print(f" Data directory not found: {data_dir}")
        return False
    
    # Count images
    total_images = 0
    for root, dirs, files in os.walk(data_dir):
        total_images += len([f for f in files if f.endswith('.jpg')])
    
    if total_images == 0:
        print(" No images found in data directory")
        return False
    
    print(f" Found {total_images} images")
    return True

def check_dependencies():
    """Check if required packages are installed"""
    required_packages = ['torch', 'torchvision', 'pandas', 'numpy', 'PIL', 'sklearn', 'matplotlib']
    missing_packages = []
    
    for package in required_packages:
        try:
            if package == 'PIL':
                from PIL import Image
            elif package == 'sklearn':
                import sklearn
            else:
                __import__(package)
            print(f" {package}")
        except ImportError:
            missing_packages.append(package)
            print(f" {package}")
    
    return missing_packages

def install_dependencies():
    """Install missing dependencies"""
    print("Installing dependencies...")
    
    # Install PyTorch first
    print("Installing PyTorch...")
    subprocess.run([
        sys.executable, "-m", "pip", "install", 
        "torch", "torchvision", "torchaudio", 
        "--index-url", "https://download.pytorch.org/whl/cpu"
    ])
    
    # Install other packages
    print("Installing other packages...")
    subprocess.run([
        sys.executable, "-m", "pip", "install",
        "pandas", "numpy", "pillow", "scikit-learn", 
        "matplotlib", "seaborn", "opencv-python", "tqdm"
    ])

def show_training_options():
    """Show training options"""
    print("\n" + "="*60)
    print(" TRAINING OPTIONS")
    print("="*60)
    
    print("\n1.  CLOUD TRAINING (Recommended)")
    print("   • Google Colab (Free GPU)")
    print("   • Kaggle Notebooks (Free GPU)")
    print("   • AWS/GCP (Paid)")
    print("   • Best performance, no local setup")
    
    print("\n2.  LOCAL TRAINING")
    print("   • Requires powerful hardware")
    print("   • GPU recommended (8GB+ VRAM)")
    print("   • Full control over training")
    
    print("\n3.  QUICK TEST")
    print("   • Test with small dataset")
    print("   • Verify everything works")
    print("   • CPU-only training")

def create_colab_notebook():
    """Create Google Colab notebook"""
    colab_content = '''# Livestock Disease Detection - Google Colab Training

## Setup
```python
# Install required packages
!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
!pip install pandas numpy pillow scikit-learn matplotlib seaborn opencv-python tqdm

# Mount Google Drive (upload your data here)
from google.colab import drive
drive.mount('/content/drive')

# Copy your data to Colab
!cp -r "/content/drive/MyDrive/your_data_folder" "/content/assets/unlabeled_data"
```

## Training
```python
# Run training
!python scripts/train_model.py
```

## Download Results
```python
# Download trained model
from google.colab import files
files.download('assets/models/livestock_disease_model.pth')
files.download('assets/models/training_curves.png')
```
'''
    
    with open('scripts/colab_training.ipynb', 'w') as f:
        f.write(colab_content)
    
    print(" Created Google Colab notebook: scripts/colab_training.ipynb")

def main():
    """Main function"""
    print("="*60)
    print(" LIVESTOCK DISEASE DETECTION - TRAINING SETUP")
    print("="*60)
    
    # Check Python version
    if not check_python_version():
        return False
    
    # Check data
    if not check_data():
        return False
    
    # Check dependencies
    print("\n Checking dependencies...")
    missing = check_dependencies()
    
    if missing:
        print(f"\n Missing packages: {', '.join(missing)}")
        choice = input("\nInstall dependencies now? (y/n): ").lower()
        if choice == 'y':
            install_dependencies()
        else:
            print("Please install dependencies manually:")
            print("pip install torch torchvision pandas numpy pillow scikit-learn matplotlib seaborn opencv-python tqdm")
            return False
    
    # Show options
    show_training_options()
    
    # Create Colab notebook
    create_colab_notebook()
    
    print("\n" + "="*60)
    print(" SETUP COMPLETE!")
    print("="*60)
    print("\n Next Steps:")
    print("1. Choose training option (Cloud/Local)")
    print("2. If local: python scripts/train_model.py")
    print("3. If cloud: Upload scripts/colab_training.ipynb to Google Colab")
    print("4. Monitor training progress")
    print("5. Download trained model")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
