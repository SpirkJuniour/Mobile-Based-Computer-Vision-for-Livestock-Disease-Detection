"""Monitor training progress and check if models are ready for integration."""
import csv
import time
from pathlib import Path
from datetime import datetime

ROOT = Path("D:/mifugo_care")
RUNS_DIR = ROOT / "ml" / "runs"
FLUTTER_ASSETS = ROOT / "assets" / "models"

def check_detection_progress():
    """Check detection model training progress."""
    detect_dirs = sorted((RUNS_DIR / "detect").glob("animal_pathologies*"), reverse=True)
    
    if not detect_dirs:
        print("[ERROR] No detection training runs found")
        return False
    
    latest_run = detect_dirs[0]
    results_csv = latest_run / "results.csv"
    
    if not results_csv.exists():
        print(f"[WAIT] Training started: {latest_run.name}")
        print("   Waiting for first results...")
        return False
    
    with open(results_csv, 'r') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        if not rows:
            print("[WAIT] Training in progress...")
            return False
        
        latest = rows[-1]
        epoch = int(latest.get('epoch', 0))
        mAP50 = float(latest.get('metrics/mAP50(B)', 0))
        precision = float(latest.get('metrics/precision(B)', 0))
        recall = float(latest.get('metrics/recall(B)', 0))
        
        print(f"\n[Detection Model] {latest_run.name}")
        print(f"   Epoch: {epoch}/50")
        print(f"   mAP50: {mAP50*100:.2f}% (target: 99-100%)")
        print(f"   Precision: {precision*100:.2f}%")
        print(f"   Recall: {recall*100:.2f}%")
        
        # Check if ONNX model exists
        onnx_file = latest_run / "weights" / "best.onnx"
        if onnx_file.exists():
            print(f"   [OK] ONNX model ready: {onnx_file.name}")
            if mAP50 >= 0.99:
                print("   [SUCCESS] Target accuracy reached!")
                return True
        else:
            print("   [WAIT] ONNX export pending...")
        
        if mAP50 >= 0.99:
            return True
        elif mAP50 >= 0.90:
            print("   [WARN] Close to target, continue training...")
        else:
            print("   [WAIT] Training in progress...")
        
        return False

def check_classification_progress():
    """Check classification model training progress."""
    classify_dirs = sorted((RUNS_DIR / "classify").glob("cattle diseases*"), reverse=True)
    
    if not classify_dirs:
        print("[ERROR] No classification training runs found")
        return False
    
    latest_run = classify_dirs[0]
    results_csv = latest_run / "results.csv"
    
    if not results_csv.exists():
        print(f"[WAIT] Training started: {latest_run.name}")
        print("   Waiting for first results...")
        return False
    
    with open(results_csv, 'r') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        if not rows:
            print("[WAIT] Training in progress...")
            return False
        
        latest = rows[-1]
        epoch = int(latest.get('epoch', 0))
        # Try different metric names
        top1 = float(latest.get('metrics/top1', latest.get('metrics/accuracy', latest.get('metrics/acc', 0))))
        
        print(f"\n[Classification Model] {latest_run.name}")
        print(f"   Epoch: {epoch}/50")
        print(f"   Top-1 Accuracy: {top1*100:.2f}% (target: 99-100%)")
        
        # Check if ONNX model exists
        onnx_file = latest_run / "weights" / "best.onnx"
        if onnx_file.exists():
            print(f"   [OK] ONNX model ready: {onnx_file.name}")
            if top1 >= 0.99:
                print("   [SUCCESS] Target accuracy reached!")
                return True
        else:
            print("   [WAIT] ONNX export pending...")
        
        if top1 >= 0.99:
            return True
        elif top1 >= 0.90:
            print("   [WARN] Close to target, continue training...")
        else:
            print("   [WAIT] Training in progress...")
        
        return False

def check_models_in_assets():
    """Check if models are already in Flutter assets."""
    detection_model = FLUTTER_ASSETS / "animal_pathologies_best.onnx"
    classification_model = FLUTTER_ASSETS / "cattle_diseases_best.onnx"
    
    print("\n[Flutter Assets Status]")
    if detection_model.exists():
        size_mb = detection_model.stat().st_size / (1024 * 1024)
        print(f"   [OK] Detection model: {detection_model.name} ({size_mb:.1f} MB)")
    else:
        print(f"   [MISSING] Detection model: Not found")
    
    if classification_model.exists():
        size_mb = classification_model.stat().st_size / (1024 * 1024)
        print(f"   [OK] Classification model: {classification_model.name} ({size_mb:.1f} MB)")
    else:
        print(f"   [MISSING] Classification model: Not found")
    
    return detection_model.exists() and classification_model.exists()

if __name__ == "__main__":
    print("=" * 60)
    print(f"Training Monitor - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    detection_ready = check_detection_progress()
    classification_ready = check_classification_progress()
    assets_ready = check_models_in_assets()
    
    print("\n" + "=" * 60)
    if detection_ready and classification_ready:
        if assets_ready:
            print("[SUCCESS] All models ready and integrated!")
            print("   Next: Test the app with camera integration")
        else:
            print("[SUCCESS] Models trained! Copy to assets:")
            print("   Run: python ml/copy_models_to_flutter.py")
    else:
        print("[WAIT] Training in progress...")
        print("   Check again in 5 minutes")
    print("=" * 60)

