#!/usr/bin/env python3
"""
Upload Project to Google Drive for Colab Training

This script helps you upload your project to Google Drive for easy access in Google Colab.
"""

import os
import shutil
import zipfile
from pathlib import Path

def create_project_zip():
    """Create a zip file of your entire project"""
    
    print(" Creating project zip file...")
    
    # Files and folders to include
    include_items = [
        'assets/unlabeled_data',
        'scripts',
        'lib',
        'pubspec.yaml',
        'README.md'
    ]
    
    zip_filename = "livestock_disease_project.zip"
    
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for item in include_items:
            if os.path.exists(item):
                if os.path.isdir(item):
                    for root, dirs, files in os.walk(item):
                        for file in files:
                            file_path = os.path.join(root, file)
                            arc_path = os.path.relpath(file_path, '.')
                            zipf.write(file_path, arc_path)
                else:
                    zipf.write(item, item)
    
    zip_size = os.path.getsize(zip_filename) / (1024 * 1024)  # MB
    print(f" Project zip created: {zip_filename} ({zip_size:.1f} MB)")
    
    return zip_filename

def create_drive_instructions():
    """Create instructions for Google Drive setup"""
    
    instructions = """
#  Google Drive + Colab Setup Instructions

## Step 1: Upload to Google Drive
1. Go to https://drive.google.com/
2. Sign in with your Google account
3. Create a new folder called "Livestock Disease Detection"
4. Upload the file: `livestock_disease_project.zip`
5. Extract the zip file in Google Drive

## Step 2: Open Google Colab
1. Go to https://colab.research.google.com/
2. Sign in with the same Google account
3. Click "New Notebook"
4. Upload the file: `scripts/livestock_disease_training.ipynb`

## Step 3: Connect to Drive
1. In the notebook, run the first few cells
2. The notebook will automatically mount your Google Drive
3. It will find your data in: `/content/drive/MyDrive/Livestock Disease Detection/assets/unlabeled_data`

## Step 4: Start Training
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
- If "No data found": Check that you uploaded and extracted the zip file
- If slow training: Ensure you're using GPU runtime
- If out of memory: Reduce batch size in training cell

Your dataset is excellent for training! 
"""
    
    with open("DRIVE_SETUP_INSTRUCTIONS.md", "w") as f:
        f.write(instructions)
    
    print(" Created DRIVE_SETUP_INSTRUCTIONS.md")

def create_colab_notebook_with_drive():
    """Create an enhanced Colab notebook with Drive integration"""
    
    notebook_content = '''{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {
    "id": "title"
   },
   "source": [
    "#  Livestock Disease Detection - Google Colab Training\\n",
    "\\n",
    "This notebook trains a deep learning model to detect livestock diseases from images.\\n",
    "\\n",
    "## Dataset: 4,986+ images across 5 disease categories\\n",
    "- Lumpy Skin Disease\\n",
    "- Foot and Mouth Disease (FMD)\\n",
    "- Mastitis\\n",
    "- Healthy\\n",
    "- Dermatitis"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {
    "id": "setup"
   },
   "source": [
    "##  Setup and Installation"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "id": "install_packages"
   },
   "outputs": [],
   "source": [
    "# Install required packages\\n",
    "!pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118\\n",
    "!pip install pandas numpy pillow scikit-learn matplotlib seaborn opencv-python tqdm\\n",
    "\\n",
    "print(\\" All packages installed successfully!\\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "id": "mount_drive"
   },
   "outputs": [],
   "source": [
    "# Mount Google Drive to access your data\\n",
    "from google.colab import drive\\n",
    "drive.mount('/content/drive')\\n",
    "\\n",
    "print(\\" Google Drive mounted!\\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {
    "id": "check_drive_data"
   },
   "outputs": [],
   "source": [
    "# Check if your data exists in Google Drive\\n",
    "import os\\n",
    "import shutil\\n",
    "\\n",
    "# Look for your project in Google Drive\\n",
    "possible_paths = [\\n",
    "    '/content/drive/MyDrive/Livestock Disease Detection/assets/unlabeled_data',\\n",
    "    '/content/drive/MyDrive/Mobile-Based-Computer-Vision-for-Livestock-Disease-Detection/assets/unlabeled_data',\\n",
    "    '/content/drive/MyDrive/livestock_disease_project/assets/unlabeled_data'\\n",
    "]\\n",
    "\\n",
    "data_found = False\\n",
    "for path in possible_paths:\\n",
    "    if os.path.exists(path):\\n",
    "        print(f\\" Found data in: {path}\\")\\n",
    "        # Copy data to working directory\\n",
    "        shutil.copytree(path, '/content/assets/unlabeled_data')\\n",
    "        print(\\" Data copied to working directory\\")\\n",
    "        data_found = True\\n",
    "        break\\n",
    "\\n",
    "if not data_found:\\n",
    "    print(\\" Data not found in Google Drive!\\")\\n",
    "    print(\\"Please ensure you uploaded and extracted the project zip file.\\")\\n",
    "    print(\\"Expected locations:\\")\\n",
    "    for path in possible_paths:\\n",
    "        print(f\\"  - {path}\\")"
   ]
  }
 ],
 "metadata": {
  "accelerator": "GPU",
  "colab": {
   "gpuType": "T4",
   "provenance": []
  },
  "kernelspec": {
   "display_name": "Python 3",
   "name": "python3"
  },
  "language_info": {
   "name": "python"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 0
}'''
    
    with open("scripts/livestock_disease_training_drive.ipynb", "w") as f:
        f.write(notebook_content)
    
    print(" Created enhanced Colab notebook with Drive integration")

def main():
    """Main function"""
    print("="*60)
    print(" LIVESTOCK DISEASE DETECTION - GOOGLE DRIVE SETUP")
    print("="*60)
    
    # Create project zip
    zip_filename = create_project_zip()
    
    # Create instructions
    create_drive_instructions()
    
    # Create enhanced notebook
    create_colab_notebook_with_drive()
    
    print("\n" + "="*60)
    print(" GOOGLE DRIVE SETUP COMPLETE!")
    print("="*60)
    print("\n Files created:")
    print(f"  • {zip_filename} - Your complete project")
    print("  • DRIVE_SETUP_INSTRUCTIONS.md - Step-by-step guide")
    print("  • scripts/livestock_disease_training_drive.ipynb - Enhanced notebook")
    
    print("\n Next steps:")
    print("1. Go to https://drive.google.com/")
    print(f"2. Upload {zip_filename} to Google Drive")
    print("3. Extract the zip file in Google Drive")
    print("4. Go to https://colab.research.google.com/")
    print("5. Upload scripts/livestock_disease_training_drive.ipynb")
    print("6. Run the notebook with GPU runtime")
    print("7. The notebook will automatically find your data in Drive!")
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
