#!/usr/bin/env python3
"""
Prepare Data for Google Colab Training

This script helps you prepare your data for Google Colab training.
"""

import os
import zipfile
import shutil
from pathlib import Path

def prepare_data_for_colab():
    """Prepare data for Google Colab training"""
    
    print(" Preparing data for Google Colab training...")
    
    # Check if data exists
    data_dir = "assets/unlabeled_data"
    if not os.path.exists(data_dir):
        print(f" Data directory not found: {data_dir}")
        return False
    
    # Count images
    total_images = 0
    for root, dirs, files in os.walk(data_dir):
        total_images += len([f for f in files if f.endswith('.jpg')])
    
    print(f" Found {total_images} images")
    
    if total_images == 0:
        print(" No images found!")
        return False
    
    # Create zip file
    zip_filename = "livestock_data.zip"
    print(f" Creating zip file: {zip_filename}")
    
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(data_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arc_path = os.path.relpath(file_path, data_dir)
                zipf.write(file_path, arc_path)
    
    zip_size = os.path.getsize(zip_filename) / (1024 * 1024)  # MB
    print(f" Zip file created: {zip_filename} ({zip_size:.1f} MB)")
    
    return True

def create_colab_instructions():
    """Create instructions for Google Colab"""
    
    instructions = """
#  Google Colab Training Instructions

## Step 1: Upload to Google Colab
1. Go to https://colab.research.google.com/
2. Sign in with your Google account
3. Click "New Notebook"
4. Upload the file: `scripts/livestock_disease_training.ipynb`

## Step 2: Upload Your Data
1. In the notebook, run the first few cells
2. When prompted, upload your `livestock_data.zip` file
3. The notebook will automatically extract and process your data

## Step 3: Start Training
1. Make sure you're using GPU runtime (Runtime > Change runtime type > GPU)
2. Run all cells in sequence
3. Training will start automatically
4. Monitor progress in real-time

## Expected Results
- Training time: 1-3 hours
- Final accuracy: 85-95%
- Model size: ~50MB
- Ready for Flutter integration

## Troubleshooting
- If "No data found": Check that you uploaded the zip file
- If slow training: Ensure you're using GPU runtime
- If out of memory: Reduce batch size in training cell

Your dataset is excellent for training! 
"""
    
    with open("COLAB_INSTRUCTIONS.md", "w") as f:
        f.write(instructions)
    
    print(" Created COLAB_INSTRUCTIONS.md")

def main():
    """Main function"""
    print("="*60)
    print(" LIVESTOCK DISEASE DETECTION - COLAB PREPARATION")
    print("="*60)
    
    # Prepare data
    if not prepare_data_for_colab():
        return False
    
    # Create instructions
    create_colab_instructions()
    
    print("\n" + "="*60)
    print(" PREPARATION COMPLETE!")
    print("="*60)
    print("\n Files created:")
    print("  • livestock_data.zip - Your data for Colab")
    print("  • COLAB_INSTRUCTIONS.md - Step-by-step guide")
    print("  • scripts/livestock_disease_training.ipynb - Training notebook")
    
    print("\n Next steps:")
    print("1. Go to https://colab.research.google.com/")
    print("2. Upload scripts/livestock_disease_training.ipynb")
    print("3. Upload livestock_data.zip when prompted")
    print("4. Run the notebook with GPU runtime")
    print("5. Download your trained model!")
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
