#!/usr/bin/env python3
"""
Setup and Training Script
Checks environment and starts training
"""

import subprocess
import sys
from pathlib import Path

def check_python_version():
    """Check Python version"""
    print("🔍 Checking Python version...")
    version = sys.version_info
    print(f"   Python {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8+ required")
        return False
    print("✅ Python version OK")
    return True

def install_requirements():
    """Install required packages"""
    print("\n📦 Installing requirements...")
    requirements_file = Path(__file__).parent / "requirements_tensorflow.txt"
    
    if not requirements_file.exists():
        print(f"❌ Requirements file not found: {requirements_file}")
        return False
    
    try:
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", "-r", str(requirements_file)
        ])
        print("✅ Requirements installed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install requirements: {e}")
        return False

def check_tensorflow():
    """Check TensorFlow installation"""
    print("\n🧠 Checking TensorFlow...")
    try:
        import tensorflow as tf
        print(f"   TensorFlow version: {tf.__version__}")
        
        # Check for GPU
        gpus = tf.config.list_physical_devices('GPU')
        if gpus:
            print(f"   ✅ GPU available: {len(gpus)} device(s)")
            for gpu in gpus:
                print(f"      - {gpu.name}")
        else:
            print("   ℹ️  No GPU found, will use CPU (slower)")
        
        return True
    except ImportError:
        print("❌ TensorFlow not installed")
        return False

def check_data():
    """Check training data"""
    print("\n📁 Checking training data...")
    data_dir = Path("assets/unlabeled_data")
    
    if not data_dir.exists():
        print(f"❌ Data directory not found: {data_dir}")
        print("   Please ensure training data is in assets/unlabeled_data/")
        return False
    
    # Check for multiclass data
    multiclass_dir = data_dir / "cattle diseases.v2i.multiclass"
    if multiclass_dir.exists():
        train_dir = multiclass_dir / "train"
        if train_dir.exists():
            image_count = len(list(train_dir.rglob("*.jpg")))
            print(f"✅ Found {image_count} training images")
            return True
    
    print("⚠️  Multiclass data structure not found")
    print("   Checking for alternative data...")
    
    # Check for any jpg images
    all_images = list(data_dir.rglob("*.jpg"))
    if all_images:
        print(f"✅ Found {len(all_images)} images in data directory")
        return True
    
    print("❌ No training images found")
    return False

def start_training():
    """Start the training process"""
    print("\n🚀 Starting training...")
    print("=" * 70)
    
    training_script = Path(__file__).parent / "train_tensorflow_model.py"
    
    if not training_script.exists():
        print(f"❌ Training script not found: {training_script}")
        return False
    
    try:
        subprocess.check_call([sys.executable, str(training_script)])
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Training failed: {e}")
        return False

def main():
    """Main setup and training pipeline"""
    print("=" * 70)
    print("🎯 TensorFlow Model Training Setup")
    print("   Livestock Disease Detection")
    print("=" * 70)
    
    # Step 1: Check Python
    if not check_python_version():
        sys.exit(1)
    
    # Step 2: Install requirements
    print("\n" + "=" * 70)
    response = input("Install/update requirements? (y/n): ").lower()
    if response == 'y':
        if not install_requirements():
            print("\n⚠️  Failed to install requirements")
            response = input("Continue anyway? (y/n): ").lower()
            if response != 'y':
                sys.exit(1)
    
    # Step 3: Check TensorFlow
    if not check_tensorflow():
        print("\n❌ TensorFlow not available")
        print("   Install with: pip install tensorflow")
        sys.exit(1)
    
    # Step 4: Check data
    if not check_data():
        print("\n❌ Training data not available")
        sys.exit(1)
    
    # Step 5: Start training
    print("\n" + "=" * 70)
    print("✅ All checks passed!")
    print("=" * 70)
    response = input("\nStart training now? (y/n): ").lower()
    
    if response == 'y':
        if start_training():
            print("\n✅ Training completed successfully!")
        else:
            print("\n❌ Training encountered errors")
            sys.exit(1)
    else:
        print("\nTraining cancelled. You can start manually with:")
        print(f"   python scripts/train_tensorflow_model.py")

if __name__ == "__main__":
    main()

