"""Check training accuracy and ensure it reaches target (95-100%)."""
import csv
from pathlib import Path

ROOT = Path("D:/mifugo_care")
RUNS_DIR = ROOT / "ml" / "runs"

def check_detection_accuracy():
    """Check detection model accuracy from results.csv"""
    detect_dirs = sorted((RUNS_DIR / "detect").glob("*"), reverse=True)
    
    for run_dir in detect_dirs[:3]:  # Check latest 3 runs
        results_csv = run_dir / "results.csv"
        if results_csv.exists():
            print(f"\n=== {run_dir.name} ===")
            with open(results_csv, 'r') as f:
                reader = csv.DictReader(f)
                rows = list(reader)
                if rows:
                    latest = rows[-1]
                    mAP50 = float(latest.get('metrics/mAP50(B)', 0))
                    mAP50_95 = float(latest.get('metrics/mAP50-95(B)', 0))
                    epoch = int(latest.get('epoch', 0))
                    
                    print(f"Epoch: {epoch}")
                    print(f"mAP50: {mAP50:.4f} ({mAP50*100:.2f}%)")
                    print(f"mAP50-95: {mAP50_95:.4f} ({mAP50_95*100:.2f}%)")
                    
                    if mAP50 >= 0.95:
                        print("✅ Target accuracy reached!")
                    elif mAP50 >= 0.90:
                        print("⚠️  Close to target, continue training...")
                    else:
                        print("⏳ Training in progress...")

def check_classification_accuracy():
    """Check classification model accuracy"""
    classify_dirs = sorted((RUNS_DIR / "classify").glob("*"), reverse=True)
    
    for run_dir in classify_dirs[:3]:  # Check latest 3 runs
        results_csv = run_dir / "results.csv"
        if results_csv.exists():
            print(f"\n=== {run_dir.name} ===")
            with open(results_csv, 'r') as f:
                reader = csv.DictReader(f)
                rows = list(reader)
                if rows:
                    latest = rows[-1]
                    # Classification metrics vary by version
                    top1 = float(latest.get('metrics/top1', latest.get('metrics/accuracy', 0)))
                    epoch = int(latest.get('epoch', 0))
                    
                    print(f"Epoch: {epoch}")
                    print(f"Top-1 Accuracy: {top1:.4f} ({top1*100:.2f}%)")
                    
                    if top1 >= 0.95:
                        print("✅ Target accuracy reached!")
                    elif top1 >= 0.90:
                        print("⚠️  Close to target, continue training...")
                    else:
                        print("⏳ Training in progress...")

if __name__ == "__main__":
    print("=== Detection Models ===")
    check_detection_accuracy()
    
    print("\n=== Classification Models ===")
    check_classification_accuracy()

