"""Reorganize classification dataset from CSV format to ImageNet-style class folders."""
import pandas as pd
from pathlib import Path
import shutil

ROOT = Path("D:/mifugo_care")
DATASET = ROOT / "datasets" / "cattle diseases.v2i.multiclass"

def reorganize_dataset():
    """Reorganize dataset into ImageNet-style class folders."""
    print("Reorganizing classification dataset...")
    
    # Read CSV to get class labels
    csv_path = DATASET / "train" / "_classes.csv"
    if not csv_path.exists():
        print(f"Error: {csv_path} not found")
        return False
    
    df = pd.read_csv(csv_path)
    
    # Get class names (skip 'filename' column) and strip whitespace
    class_columns = [col.strip() for col in df.columns if col != 'filename']
    print(f"Found classes: {class_columns}")
    
    # Create class folders in train, valid, test
    for split in ['train', 'valid', 'test']:
        split_dir = DATASET / split
        if not split_dir.exists():
            continue
            
        print(f"\nProcessing {split}...")
        
        # Create class folders
        for class_name in class_columns:
            class_dir = split_dir / class_name
            class_dir.mkdir(exist_ok=True)
        
        # Read CSV for this split if it exists
        split_csv = split_dir / "_classes.csv"
        if split_csv.exists():
            split_df = pd.read_csv(split_csv)
            
            # Move images to class folders
            for _, row in split_df.iterrows():
                filename = row['filename']
                img_path = split_dir / filename
                
                if not img_path.exists():
                    continue
                
                # Find which class this image belongs to (1 = positive)
                for class_col in df.columns:
                    if class_col == 'filename':
                        continue
                    class_name = class_col.strip()
                    if row[class_col] == 1:
                        dest = split_dir / class_name / filename
                        if not dest.exists():
                            shutil.move(str(img_path), str(dest))
                        break
    
    print("\n[SUCCESS] Dataset reorganization complete!")
    print("Structure should now be:")
    print("  train/class1/image.jpg")
    print("  train/class2/image.jpg")
    print("  etc.")
    return True

if __name__ == "__main__":
    reorganize_dataset()

