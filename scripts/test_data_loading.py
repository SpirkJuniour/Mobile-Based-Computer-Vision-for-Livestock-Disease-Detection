#!/usr/bin/env python3
"""
Quick test script to verify all 4 datasets load correctly
Run this before starting the full training
"""

import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

print("\n" + "="*70)
print("  DATA LOADING TEST - Verifying All 4 Datasets")
print("="*70 + "\n")

try:
    from PIL import Image
    import torch
    import torchvision.transforms as transforms
    from tqdm import tqdm
    import numpy as np
    
    print("✓ All required packages imported successfully\n")
    
    # Check GPU availability
    print("GPU Check:")
    print("-" * 70)
    if torch.cuda.is_available():
        print(f"✓ CUDA is available!")
        print(f"  GPU: {torch.cuda.get_device_name(0)}")
        print(f"  Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.2f} GB")
    else:
        print("⚠ CUDA is NOT available - training will be slow on CPU")
        print("  Install PyTorch with CUDA: pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
    print()
    
    # Define paths
    DATA_DIR = Path("assets/unlabeled_data")
    
    datasets_info = {
        "lcaugmented": {
            "path": DATA_DIR / "lcaugmented",
            "expected_label": "lumpy_skin",
            "pattern": "*.jpg"
        },
        "hcaugmented": {
            "path": DATA_DIR / "hcaugmented",
            "expected_label": "healthy",
            "pattern": "*.jpg"
        },
        "cattle diseases.v2i.yolov11": {
            "path": DATA_DIR / "cattle diseases.v2i.yolov11",
            "expected_label": "mixed",
            "subdirs": ["train", "valid", "test"]
        },
        "cattle diseases.v2i.multiclass": {
            "path": DATA_DIR / "cattle diseases.v2i.multiclass",
            "expected_label": "mixed",
            "subdirs": ["train", "valid", "test"]
        }
    }
    
    print("Dataset Loading Test:")
    print("="*70)
    
    total_images = 0
    corrupted_images = []
    class_counts = {
        'healthy': 0,
        'lumpy_skin': 0,
        'fmd': 0,
        'mastitis': 0,
        'dermatitis': 0,
        'unknown': 0
    }
    
    # Test transform
    test_transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor()
    ])
    
    def infer_label(filename):
        """Infer label from filename"""
        fn = filename.lower()
        if any(kw in fn for kw in ['lumpy', 'lsd']):
            return 'lumpy_skin'
        elif any(kw in fn for kw in ['fmd', 'foot']):
            return 'fmd'
        elif 'mastitis' in fn:
            return 'mastitis'
        elif any(kw in fn for kw in ['dermatitis', 'fungal']):
            return 'dermatitis'
        elif any(kw in fn for kw in ['healthy', 'sehat', 'normal', 'ayrshire', 'jersey', 'holstein', 'cattle']):
            return 'healthy'
        return 'unknown'
    
    # Test each dataset
    for dataset_name, info in datasets_info.items():
        print(f"\n[{list(datasets_info.keys()).index(dataset_name) + 1}/4] Testing: {dataset_name}")
        print("-" * 70)
        
        if not info["path"].exists():
            print(f"  ✗ ERROR: Directory not found: {info['path']}")
            continue
        
        # Collect images
        images = []
        if "subdirs" in info:
            for subdir in info["subdirs"]:
                subdir_path = info["path"] / subdir
                if subdir_path.exists():
                    images.extend(list(subdir_path.glob("*.jpg")))
        else:
            images = list(info["path"].glob(info["pattern"]))
        
        print(f"  Found {len(images)} images")
        
        if len(images) == 0:
            print(f"  ⚠ WARNING: No images found!")
            continue
        
        # Test loading first few images
        test_count = min(10, len(images))
        print(f"  Testing {test_count} sample images...")
        
        valid_count = 0
        for img_path in images[:test_count]:
            try:
                img = Image.open(img_path).convert('RGB')
                tensor = test_transform(img)
                valid_count += 1
            except Exception as e:
                corrupted_images.append((str(img_path), str(e)))
        
        if valid_count == test_count:
            print(f"  ✓ All {test_count} test images loaded successfully")
        else:
            print(f"  ⚠ Only {valid_count}/{test_count} images loaded successfully")
        
        # Count labels
        print(f"  Inferring labels from filenames...")
        local_counts = {'healthy': 0, 'lumpy_skin': 0, 'fmd': 0, 'mastitis': 0, 'dermatitis': 0, 'unknown': 0}
        
        if dataset_name == "lcaugmented":
            local_counts['lumpy_skin'] = len(images)
        elif dataset_name == "hcaugmented":
            local_counts['healthy'] = len(images)
        else:
            for img_path in images:
                label = infer_label(img_path.name)
                local_counts[label] += 1
        
        # Display distribution
        print(f"  Label distribution:")
        for label, count in local_counts.items():
            if count > 0:
                print(f"    {label:15s}: {count:5d}")
                class_counts[label] += count
        
        total_images += len(images)
        print(f"  ✓ Dataset tested successfully")
    
    # Summary
    print("\n" + "="*70)
    print("  SUMMARY")
    print("="*70)
    print(f"\nTotal Images Found: {total_images}")
    
    print(f"\nOverall Class Distribution:")
    print("-" * 70)
    for label, count in class_counts.items():
        if count > 0:
            percentage = (count / total_images * 100) if total_images > 0 else 0
            print(f"  {label:15s}: {count:5d} ({percentage:5.2f}%)")
    
    if corrupted_images:
        print(f"\n⚠ Found {len(corrupted_images)} corrupted images:")
        for img_path, error in corrupted_images[:5]:
            print(f"  - {img_path}: {error}")
        if len(corrupted_images) > 5:
            print(f"  ... and {len(corrupted_images) - 5} more")
    else:
        print(f"\n✓ No corrupted images found!")
    
    # Recommendations
    print("\n" + "="*70)
    print("  RECOMMENDATIONS")
    print("="*70)
    
    if total_images < 1000:
        print("⚠ Dataset is small (<1000 images). Model may not reach high accuracy.")
    elif total_images < 3000:
        print("✓ Dataset size is adequate. Should achieve good accuracy.")
    else:
        print("✓ Dataset size is excellent! Should achieve high accuracy.")
    
    # Check class balance
    non_zero_counts = [v for v in class_counts.values() if v > 0]
    if non_zero_counts:
        max_count = max(non_zero_counts)
        min_count = min(non_zero_counts)
        imbalance_ratio = max_count / min_count if min_count > 0 else float('inf')
        
        if imbalance_ratio > 5:
            print(f"⚠ Class imbalance detected (ratio: {imbalance_ratio:.1f}:1)")
            print("  Training script uses weighted sampling to handle this.")
        else:
            print(f"✓ Classes are reasonably balanced (ratio: {imbalance_ratio:.1f}:1)")
    
    if torch.cuda.is_available():
        print("✓ GPU is available - training will be fast!")
    else:
        print("⚠ No GPU detected - training will be VERY slow on CPU")
        print("  Recommendation: Install CUDA-enabled PyTorch")
    
    print("\n" + "="*70)
    print("  DATA VERIFICATION COMPLETE")
    print("="*70)
    
    if total_images > 0 and len(corrupted_images) == 0:
        print("\n✓✓✓ All systems ready for training! ✓✓✓")
        print("\nTo start training, run:")
        print("  python scripts/train_livestock_model.py")
    else:
        print("\n⚠ Please fix the issues above before training")
    
    print()

except ImportError as e:
    print(f"\n❌ Import Error: {e}")
    print("\nPlease install required packages:")
    print("  pip install -r requirements.txt")
    print("  pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118")
    
except Exception as e:
    print(f"\n❌ Error during testing: {e}")
    import traceback
    traceback.print_exc()

