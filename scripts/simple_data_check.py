#!/usr/bin/env python3
"""
Simple Data Check Script for Livestock Disease Detection

This script checks your data structure without requiring heavy ML dependencies.
"""

import os
import sys
from pathlib import Path
import json

def check_data_structure():
    """Check if the data structure is correct"""
    print(" Checking data structure...")
    
    data_dir = "assets/unlabeled_data"
    
    if not os.path.exists(data_dir):
        print(f" Data directory not found: {data_dir}")
        return False
    
    print(f" Data directory exists: {data_dir}")
    
    # Check for expected folders
    expected_folders = [
        "cattle diseases.v2i.multiclass",
        "cattle diseases.v2i.yolov11", 
        "hcaugmented",
        "lcaugmented"
    ]
    
    found_folders = []
    for folder in expected_folders:
        folder_path = os.path.join(data_dir, folder)
        if os.path.exists(folder_path):
            found_folders.append(folder)
            print(f" Found: {folder}")
        else:
            print(f" Missing: {folder}")
    
    return len(found_folders) > 0

def count_images():
    """Count images in each dataset"""
    print("\n Counting images...")
    
    data_dir = "assets/unlabeled_data"
    total_images = 0
    
    # Count multiclass dataset
    multiclass_dir = os.path.join(data_dir, "cattle diseases.v2i.multiclass")
    if os.path.exists(multiclass_dir):
        for split in ['train', 'valid', 'test']:
            split_dir = os.path.join(multiclass_dir, split)
            if os.path.exists(split_dir):
                jpg_files = [f for f in os.listdir(split_dir) if f.endswith('.jpg')]
                print(f"  {split}: {len(jpg_files)} images")
                total_images += len(jpg_files)
    
    # Count YOLO dataset
    yolo_dir = os.path.join(data_dir, "cattle diseases.v2i.yolov11")
    if os.path.exists(yolo_dir):
        for split in ['train', 'valid', 'test']:
            split_dir = os.path.join(yolo_dir, split)
            if os.path.exists(split_dir):
                jpg_files = [f for f in os.listdir(split_dir) if f.endswith('.jpg')]
                print(f"  YOLO {split}: {len(jpg_files)} images")
                total_images += len(jpg_files)
    
    # Count augmented datasets
    for aug_dir in ['hcaugmented', 'lcaugmented']:
        aug_path = os.path.join(data_dir, aug_dir)
        if os.path.exists(aug_path):
            jpg_files = [f for f in os.listdir(aug_path) if f.endswith('.jpg')]
            print(f"  {aug_dir}: {len(jpg_files)} images")
            total_images += len(jpg_files)
    
    print(f"\n Total images: {total_images}")
    return total_images

def check_csv_files():
    """Check CSV files for labels"""
    print("\n Checking label files...")
    
    data_dir = "assets/unlabeled_data"
    multiclass_dir = os.path.join(data_dir, "cattle diseases.v2i.multiclass")
    
    if os.path.exists(multiclass_dir):
        for split in ['train', 'valid', 'test']:
            split_dir = os.path.join(multiclass_dir, split)
            csv_file = os.path.join(split_dir, '_classes.csv')
            
            if os.path.exists(csv_file):
                print(f" Found labels: {split}/_classes.csv")
                try:
                    import pandas as pd
                    df = pd.read_csv(csv_file)
                    print(f"    Columns: {list(df.columns)}")
                    print(f"    Rows: {len(df)}")
                except ImportError:
                    print("    (pandas not installed - cannot read CSV)")
                except Exception as e:
                    print(f"    Error reading CSV: {e}")
            else:
                print(f" Missing labels: {split}/_classes.csv")

def create_training_plan():
    """Create a training plan based on available data"""
    print("\n Training Plan:")
    
    total_images = count_images()
    
    if total_images > 1000:
        print(" Excellent dataset size for training!")
        print(" Recommended approach:")
        print("   1. Use 70% for training, 15% validation, 15% test")
        print("   2. Train for 50-100 epochs")
        print("   3. Use data augmentation")
        print("   4. Expected accuracy: 85-95%")
    elif total_images > 500:
        print(" Good dataset size for training!")
        print(" Recommended approach:")
        print("   1. Use transfer learning")
        print("   2. Train for 30-50 epochs")
        print("   3. Use data augmentation")
        print("   4. Expected accuracy: 80-90%")
    else:
        print("  Small dataset - consider data augmentation")
        print(" Recommended approach:")
        print("   1. Use transfer learning")
        print("   2. Heavy data augmentation")
        print("   3. Train for 20-30 epochs")
        print("   4. Expected accuracy: 70-85%")

def main():
    """Main function"""
    print("="*60)
    print(" LIVESTOCK DISEASE DETECTION - DATA CHECK")
    print("="*60)
    
    # Check data structure
    if not check_data_structure():
        print("\n Data structure issues found!")
        print("Please ensure your data is in assets/unlabeled_data/")
        return False
    
    # Count images
    total_images = count_images()
    
    if total_images == 0:
        print("\n No images found!")
        return False
    
    # Check CSV files
    check_csv_files()
    
    # Create training plan
    create_training_plan()
    
    print("\n" + "="*60)
    print(" DATA CHECK COMPLETED!")
    print("="*60)
    print(f" Total images found: {total_images}")
    print(" Ready for training setup!")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
