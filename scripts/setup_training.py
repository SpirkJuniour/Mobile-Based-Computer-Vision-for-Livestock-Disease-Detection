#!/usr/bin/env python3
"""
Setup script for Livestock Disease Detection Training

This script helps set up the training environment and provides instructions.
"""

import os
import sys
from pathlib import Path

def check_requirements():
    """Check if required packages are installed"""
    required_packages = [
        'torch', 'torchvision', 'pandas', 'numpy', 'PIL', 
        'sklearn', 'matplotlib', 'seaborn'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            if package == 'PIL':
                from PIL import Image
            elif package == 'sklearn':
                import sklearn
            else:
                __import__(package)
            print(f"✓ {package} is installed")
        except ImportError:
            missing_packages.append(package)
            print(f"✗ {package} is missing")
    
    return missing_packages

def setup_directories():
    """Create necessary directories"""
    directories = [
        'assets/models',
        'assets/training_data',
        'scripts/logs',
        'scripts/checkpoints'
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"Created directory: {directory}")

def print_instructions():
    """Print setup and training instructions"""
    print("\n" + "="*60)
    print("LIVESTOCK DISEASE DETECTION - TRAINING SETUP")
    print("="*60)
    
    print("\n1. INSTALL REQUIREMENTS:")
    print("   pip install -r scripts/requirements.txt")
    
    print("\n2. DATA STRUCTURE:")
    print("   Your data is already organized in assets/unlabeled_data/")
    print("   - cattle diseases.v2i.multiclass/ (837 images)")
    print("   - cattle diseases.v2i.yolov11/ (2,802 images)")
    print("   - hcaugmented/ (1,500 images)")
    print("   - lcaugmented/ (1,013 images)")
    
    print("\n3. START TRAINING:")
    print("   python scripts/train_model.py")
    
    print("\n4. MONITORING:")
    print("   - Training progress will be displayed in console")
    print("   - Model will be saved to assets/models/")
    print("   - Training curves will be saved as PNG")
    
    print("\n5. MODEL DEPLOYMENT:")
    print("   - Trained model will be in assets/models/livestock_disease_model.pth")
    print("   - Convert to TensorFlow Lite for mobile deployment")
    print("   - Update Flutter app's ML service")
    
    print("\n6. EXPECTED RESULTS:")
    print("   - Training time: 1-3 hours (depending on hardware)")
    print("   - Target accuracy: >85% on validation set")
    print("   - Model size: ~50MB (ResNet18)")
    
    print("\n" + "="*60)

def main():
    """Main setup function"""
    print("Setting up Livestock Disease Detection Training Environment...")
    
    # Check requirements
    print("\nChecking requirements...")
    missing = check_requirements()
    
    if missing:
        print(f"\nMissing packages: {', '.join(missing)}")
        print("Please install them with: pip install -r scripts/requirements.txt")
        return
    
    # Setup directories
    print("\nSetting up directories...")
    setup_directories()
    
    # Print instructions
    print_instructions()
    
    print("\nSetup complete! You can now start training.")
    print("Run: python scripts/train_model.py")

if __name__ == "__main__":
    main()
