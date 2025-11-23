"""Ensure training completes successfully - monitors and restarts if needed."""
import time
import subprocess
import sys
import os
from pathlib import Path
from datetime import datetime, timedelta

ROOT = Path(__file__).parent.parent
TRAIN_SCRIPT = ROOT / "ml" / "train_all.py"
MONITOR_SCRIPT = ROOT / "ml" / "monitor_training.py"
MAX_RUNTIME_HOURS = 48  # Maximum expected training time
CHECK_INTERVAL = 300  # 5 minutes

def check_training_process():
    """Check if training process is running."""
    try:
        import psutil
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                if proc.info['name'] and 'python' in proc.info['name'].lower():
                    cmdline = proc.info.get('cmdline', [])
                    if cmdline and 'train_all.py' in ' '.join(cmdline):
                        return proc.info['pid'], proc
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
    except ImportError:
        # Fallback: use basic process check
        import subprocess
        result = subprocess.run(
            ['tasklist', '/FI', 'IMAGENAME eq python.exe', '/FO', 'CSV'],
            capture_output=True,
            text=True
        )
        if 'python.exe' in result.stdout:
            return True, None
    return False, None

def check_training_progress():
    """Check if training is making progress."""
    runs_dir = ROOT / "ml" / "runs"
    
    # Check detection runs
    detect_dirs = sorted((runs_dir / "detect").glob("animal_pathologies*"), reverse=True)
    if detect_dirs:
        latest = detect_dirs[0]
        results_csv = latest / "results.csv"
        if results_csv.exists():
            # Check if file was updated recently
            mod_time = datetime.fromtimestamp(results_csv.stat().st_mtime)
            if datetime.now() - mod_time < timedelta(minutes=30):
                return True, f"Detection: results updated {mod_time.strftime('%H:%M:%S')}"
    
    # Check classification runs
    classify_dirs = sorted((runs_dir / "classify").glob("cattle diseases*"), reverse=True)
    if classify_dirs:
        latest = classify_dirs[0]
        results_csv = latest / "results.csv"
        if results_csv.exists():
            mod_time = datetime.fromtimestamp(results_csv.stat().st_mtime)
            if datetime.now() - mod_time < timedelta(minutes=30):
                return True, f"Classification: results updated {mod_time.strftime('%H:%M:%S')}"
    
    return False, "No recent progress detected"

def run_monitor():
    """Run the monitoring script."""
    try:
        result = subprocess.run(
            [sys.executable, str(MONITOR_SCRIPT)],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
            timeout=60
        )
        return result.stdout
    except Exception as e:
        return f"Error running monitor: {e}"

def main():
    print("=" * 60)
    print("Training Completion Monitor")
    print("Ensuring training completes successfully")
    print("=" * 60)
    print()
    
    start_time = datetime.now()
    check_count = 0
    no_progress_count = 0
    max_no_progress = 12  # 1 hour without progress
    
    while True:
        check_count += 1
        elapsed = datetime.now() - start_time
        
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Check #{check_count}")
        print(f"Elapsed time: {elapsed}")
        print("-" * 60)
        
        # Check if process is running
        is_running, proc = check_training_process()
        
        if not is_running:
            print("[WARNING] Training process not found!")
            print("Checking if training completed...")
            
            # Run monitor to check status
            monitor_output = run_monitor()
            print(monitor_output)
            
            # Check if models are ready
            assets_dir = ROOT / "assets" / "models"
            detection_model = assets_dir / "animal_pathologies_best.onnx"
            classification_model = assets_dir / "cattle_diseases_best.onnx"
            
            if detection_model.exists() and classification_model.exists():
                print("\n[SUCCESS] Training appears to have completed!")
                print("Models found in assets directory")
                break
            else:
                print("\n[ERROR] Training stopped but models not ready")
                print("Restarting training...")
                try:
                    subprocess.Popen(
                        [sys.executable, str(TRAIN_SCRIPT)],
                        cwd=str(ROOT / "ml"),
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE
                    )
                    print("Training restarted")
                    time.sleep(60)  # Wait before next check
                except Exception as e:
                    print(f"Failed to restart: {e}")
        else:
            # Process is running, check for progress
            has_progress, progress_msg = check_training_progress()
            
            if has_progress:
                no_progress_count = 0
                print(f"[OK] {progress_msg}")
            else:
                no_progress_count += 1
                print(f"[WARN] {progress_msg}")
                print(f"No progress detected: {no_progress_count}/{max_no_progress} checks")
                
                if no_progress_count >= max_no_progress:
                    print("\n[WARNING] No progress for 1 hour!")
                    print("Training may be stuck. Check manually.")
            
            # Run monitor
            monitor_output = run_monitor()
            print(monitor_output)
        
        # Check if max runtime exceeded
        if elapsed > timedelta(hours=MAX_RUNTIME_HOURS):
            print(f"\n[WARNING] Maximum runtime ({MAX_RUNTIME_HOURS} hours) exceeded")
            print("Please check training status manually")
            break
        
        print()
        print("Next check in 5 minutes...")
        print()
        
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n" + "=" * 60)
        print("Monitoring stopped by user")
        print("=" * 60)

