"""Copy trained ONNX models to Flutter assets directory."""
import shutil
from pathlib import Path
from datetime import datetime

ROOT = Path("D:/mifugo_care")
ML_RUNS = ROOT / "ml" / "runs"
FLUTTER_ASSETS = ROOT / "assets" / "models"

FLUTTER_ASSETS.mkdir(parents=True, exist_ok=True)

print("=" * 60)
print("[COPY] Copying ONNX Models to Flutter Assets")
print("=" * 60)

# Find latest detection model
detect_dirs = sorted((ML_RUNS / "detect").glob("animal_pathologies*"), reverse=True)
detection_copied = False
if detect_dirs:
    latest_detect = detect_dirs[0] / "weights" / "best.onnx"
    if latest_detect.exists():
        dest = FLUTTER_ASSETS / "animal_pathologies_best.onnx"
        shutil.copy2(latest_detect, dest)
        size_mb = dest.stat().st_size / (1024 * 1024)
        print(f"[OK] Detection model copied:")
        print(f"   From: {latest_detect}")
        print(f"   To:   {dest}")
        print(f"   Size: {size_mb:.2f} MB")
        detection_copied = True
    else:
        print(f"[ERROR] Detection model not found: {latest_detect}")
else:
    print("[ERROR] No detection training runs found")

# Find latest classification model
classify_dirs = sorted((ML_RUNS / "classify").glob("cattle diseases*"), reverse=True)
classification_copied = False
if classify_dirs:
    latest_classify = classify_dirs[0] / "weights" / "best.onnx"
    if latest_classify.exists():
        dest = FLUTTER_ASSETS / "cattle_diseases_best.onnx"
        shutil.copy2(latest_classify, dest)
        size_mb = dest.stat().st_size / (1024 * 1024)
        print(f"\n[OK] Classification model copied:")
        print(f"   From: {latest_classify}")
        print(f"   To:   {dest}")
        print(f"   Size: {size_mb:.2f} MB")
        classification_copied = True
    else:
        print(f"\n[ERROR] Classification model not found: {latest_classify}")
else:
    print("\n[ERROR] No classification training runs found")

print("\n" + "=" * 60)
if detection_copied and classification_copied:
    print("[SUCCESS] All models copied successfully!")
    print("\nNext steps:")
    print("1. Run: flutter clean && flutter pub get")
    print("2. Test with camera integration")
    print("3. Verify disease detection is working")
elif detection_copied or classification_copied:
    print("[WARNING] Partial copy - some models missing")
    print("   Check training status: python ml/monitor_training.py")
else:
    print("[ERROR] No models copied - training may not be complete")
    print("   Check training status: python ml/monitor_training.py")
print("=" * 60)

