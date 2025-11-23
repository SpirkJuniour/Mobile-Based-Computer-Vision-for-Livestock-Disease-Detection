"""Export existing trained models to ONNX format for Flutter integration."""
import sys
from pathlib import Path

ROOT = Path("D:/mifugo_care")
ML_RUNS = ROOT / "ml" / "runs"
FLUTTER_ASSETS = ROOT / "assets" / "models"

FLUTTER_ASSETS.mkdir(parents=True, exist_ok=True)

from ultralytics import YOLO

def export_model(model_path: Path, output_name: str, imgsz: int = 640):
    """Export a PyTorch model to ONNX format."""
    try:
        if not model_path.exists():
            print(f"Model not found: {model_path}")
            return False
        
        print(f"Exporting {model_path.name} to ONNX...")
        model = YOLO(str(model_path))
        model.export(format="onnx", imgsz=imgsz, simplify=True)
        
        # Copy to Flutter assets
        onnx_path = model_path.parent / f"{model_path.stem}.onnx"
        if onnx_path.exists():
            import shutil
            shutil.copy2(onnx_path, FLUTTER_ASSETS / output_name)
            print(f"✅ Exported and copied: {FLUTTER_ASSETS / output_name}")
            return True
        else:
            print(f"❌ ONNX export failed for {model_path}")
            return False
    except Exception as e:
        print(f"❌ Error exporting {model_path}: {e}")
        return False

# Find and export detection models
print("=== Exporting Detection Models ===")
detect_dirs = sorted((ML_RUNS / "detect").glob("*"), reverse=True)
for run_dir in detect_dirs[:3]:  # Check latest 3 runs
    best_pt = run_dir / "weights" / "best.pt"
    if best_pt.exists():
        if "animal_pathologies" in run_dir.name:
            export_model(best_pt, "animal_pathologies_best.onnx", imgsz=640)
        elif "cattle" in run_dir.name.lower() or "cow" in run_dir.name.lower():
            export_model(best_pt, f"{run_dir.name.split('_')[0]}_best.onnx", imgsz=640)
        break  # Export only the latest

# Find and export classification models
print("\n=== Exporting Classification Models ===")
if (ML_RUNS / "classify").exists():
    classify_dirs = sorted((ML_RUNS / "classify").glob("*"), reverse=True)
    for run_dir in classify_dirs[:1]:  # Check latest run
        best_pt = run_dir / "weights" / "best.pt"
        if best_pt.exists():
            export_model(best_pt, "cattle_diseases_best.onnx", imgsz=224)
            break

print("\n✅ Model export complete! Models are in:", FLUTTER_ASSETS)

