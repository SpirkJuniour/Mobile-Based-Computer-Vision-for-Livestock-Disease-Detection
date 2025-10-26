#!/usr/bin/env python3
"""
Simple Colab Setup for Livestock Disease Detection

This script creates the essential files for Google Colab training.
"""

import os
import shutil

def create_colab_folder():
    """Create a folder for Colab training"""
    
    print("Creating Colab training folder...")
    
    # Create colab directory
    colab_dir = "colab_training"
    if os.path.exists(colab_dir):
        shutil.rmtree(colab_dir)
    os.makedirs(colab_dir, exist_ok=True)
    
    # Copy the training notebook
    if os.path.exists("scripts/livestock_disease_training.ipynb"):
        shutil.copy("scripts/livestock_disease_training.ipynb", colab_dir)
        print(" Copied training notebook")
    
    # Create data directory structure
    data_dir = os.path.join(colab_dir, "assets", "unlabeled_data")
    os.makedirs(data_dir, exist_ok=True)
    
    # Create a simple README
    readme_content = """# Livestock Disease Detection - Training Data

This folder contains the training data for the livestock disease detection model.

## Structure:
- cattle diseases.v2i.multiclass/ - Multiclass dataset
- cattle diseases.v2i.yolov11/ - YOLO dataset  
- hcaugmented/ - Healthy cattle augmented
- lcaugmented/ - Lumpy cattle augmented

## Total Images: 4,986+

## Usage in Colab:
1. Upload this entire folder to Google Drive
2. The Colab notebook will automatically find and use this data
3. Training will start automatically with GPU acceleration

## Expected Results:
- Training time: 1-3 hours
- Final accuracy: 85-95%
- Model size: ~50MB
- Ready for Flutter integration
"""
    
    with open(os.path.join(colab_dir, "README.md"), "w", encoding='utf-8') as f:
        f.write(readme_content)
    
    print(" Created README")
    
    return colab_dir

def create_instructions():
    """Create simple instructions"""
    
    instructions = """# Google Drive Upload Instructions

## Step 1: Prepare Your Data
1. Navigate to the colab_training folder created by this script
2. Copy your assets/unlabeled_data folder into colab_training/assets/unlabeled_data
3. Ensure you have all 4,986+ images in the correct structure

## Step 2: Upload to Google Drive
1. Go to https://drive.google.com/
2. Sign in with your Google account
3. Create a new folder called "Livestock Disease Detection"
4. Upload the entire colab_training folder to Google Drive

## Step 3: Open Google Colab
1. Go to https://colab.research.google.com/
2. Sign in with the same Google account
3. Click "New Notebook"
4. Upload the file: colab_training/livestock_disease_training.ipynb

## Step 4: Start Training
1. Make sure you're using GPU runtime (Runtime > Change runtime type > GPU)
2. Run all cells in sequence
3. The notebook will automatically find your data in Google Drive
4. Training will start automatically

## Expected Results:
- Training time: 1-3 hours
- Final accuracy: 85-95%
- Model size: ~50MB
- Ready for Flutter integration

## Troubleshooting:
- If "No data found": Check that you uploaded the complete folder structure
- If slow training: Ensure you're using GPU runtime
- If out of memory: Reduce batch size in training cell

Your dataset is excellent for training!
"""
    
    with open("UPLOAD_INSTRUCTIONS.md", "w", encoding='utf-8') as f:
        f.write(instructions)
    
    print(" Created UPLOAD_INSTRUCTIONS.md")

def main():
    """Main function"""
    print("="*60)
    print("LIVESTOCK DISEASE DETECTION - COLAB SETUP")
    print("="*60)
    
    # Create colab folder
    colab_dir = create_colab_folder()
    
    # Create instructions
    create_instructions()
    
    print("\n" + "="*60)
    print("COLAB SETUP COMPLETE!")
    print("="*60)
    print(f"\nCreated folder: {colab_dir}")
    print("\nNext steps:")
    print("1. Copy your assets/unlabeled_data folder into the colab_training folder")
    print("2. Upload the entire colab_training folder to Google Drive")
    print("3. Open Google Colab and upload the notebook")
    print("4. Run with GPU runtime for best performance")
    
    print(f"\nFiles to upload to Google Drive:")
    print(f"  • {colab_dir}/livestock_disease_training.ipynb")
    print(f"  • {colab_dir}/assets/unlabeled_data/ (your data)")
    print(f"  • {colab_dir}/README.md")
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
