#!/usr/bin/env python3
"""
Test script for Livestock Disease Detection Training

This script tests the training pipeline with a small subset of data.
"""

import os
import sys
import torch
from pathlib import Path

def test_data_loading():
    """Test data loading functionality"""
    print("Testing data loading...")
    
    try:
        # Import the training module
        sys.path.append(os.path.dirname(os.path.abspath(__file__)))
        from train_model import load_and_process_data, validate_data
        
        data_dir = "assets/unlabeled_data"
        
        if not os.path.exists(data_dir):
            print(f"Data directory not found: {data_dir}")
            return False
        
        # Load data
        image_paths, labels = load_and_process_data(data_dir)
        
        if len(image_paths) == 0:
            print("No images loaded!")
            return False
        
        print(f" Loaded {len(image_paths)} images")
        
        # Validate data
        validate_data(image_paths, labels)
        
        print(" Data loading test passed!")
        return True
        
    except Exception as e:
        print(f" Data loading test failed: {e}")
        return False

def test_model_creation():
    """Test model creation"""
    print("Testing model creation...")
    
    try:
        from train_model import DiseaseClassifier
        
        # Create model
        model = DiseaseClassifier(num_classes=5)
        
        # Test forward pass with dummy data
        dummy_input = torch.randn(1, 3, 224, 224)
        output = model(dummy_input)
        
        if output.shape == (1, 5):
            print(" Model creation test passed!")
            return True
        else:
            print(f" Unexpected output shape: {output.shape}")
            return False
            
    except Exception as e:
        print(f" Model creation test failed: {e}")
        return False

def test_data_transforms():
    """Test data transforms"""
    print("Testing data transforms...")
    
    try:
        from train_model import create_data_transforms
        from PIL import Image
        import torch
        
        train_transform, val_transform = create_data_transforms()
        
        # Create dummy image
        dummy_image = Image.new('RGB', (224, 224), color='red')
        
        # Test transforms
        train_tensor = train_transform(dummy_image)
        val_tensor = val_transform(dummy_image)
        
        if train_tensor.shape == (3, 224, 224) and val_tensor.shape == (3, 224, 224):
            print(" Data transforms test passed!")
            return True
        else:
            print(f" Unexpected tensor shapes: {train_tensor.shape}, {val_tensor.shape}")
            return False
            
    except Exception as e:
        print(f" Data transforms test failed: {e}")
        return False

def test_dataset_creation():
    """Test dataset creation"""
    print("Testing dataset creation...")
    
    try:
        from train_model import LivestockDataset, create_data_transforms
        from PIL import Image
        import tempfile
        
        # Create temporary test images
        test_images = []
        test_labels = []
        
        with tempfile.TemporaryDirectory() as temp_dir:
            for i in range(5):
                # Create dummy image
                img_path = os.path.join(temp_dir, f"test_{i}.jpg")
                img = Image.new('RGB', (224, 224), color='red')
                img.save(img_path)
                test_images.append(img_path)
                test_labels.append(i % 5)  # 5 different labels
            
            # Create transforms
            train_transform, val_transform = create_data_transforms()
            
            # Create dataset
            dataset = LivestockDataset(test_images, test_labels, train_transform)
            
            # Test dataset
            if len(dataset) == 5:
                sample_image, sample_label = dataset[0]
                if sample_image.shape == (3, 224, 224) and isinstance(sample_label, int):
                    print(" Dataset creation test passed!")
                    return True
                else:
                    print(f" Unexpected sample: {sample_image.shape}, {sample_label}")
                    return False
            else:
                print(f" Unexpected dataset length: {len(dataset)}")
                return False
                
    except Exception as e:
        print(f" Dataset creation test failed: {e}")
        return False

def run_all_tests():
    """Run all tests"""
    print("="*50)
    print("LIVESTOCK DISEASE DETECTION - TRAINING TESTS")
    print("="*50)
    
    tests = [
        ("Data Loading", test_data_loading),
        ("Model Creation", test_model_creation),
        ("Data Transforms", test_data_transforms),
        ("Dataset Creation", test_dataset_creation),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{test_name}:")
        if test_func():
            passed += 1
        else:
            print(f" {test_name} failed")
    
    print("\n" + "="*50)
    print(f"TESTS COMPLETED: {passed}/{total} passed")
    
    if passed == total:
        print(" All tests passed! Training pipeline is ready.")
        return True
    else:
        print("  Some tests failed. Please fix issues before training.")
        return False

if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
