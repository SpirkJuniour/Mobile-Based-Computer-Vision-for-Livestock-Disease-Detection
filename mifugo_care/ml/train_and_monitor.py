"""Run training and monitor progress every 5 minutes."""
import subprocess
import sys
import os
import threading
import time
import io
from pathlib import Path
from datetime import datetime
import torch

# Fix Windows console encoding for emojis
if sys.platform == 'win32':
    # Set environment variable for UTF-8 encoding
    os.environ['PYTHONIOENCODING'] = 'utf-8'
    # Try to set console to UTF-8
    try:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
    except AttributeError:
        # If buffer doesn't exist, just continue
        pass

ROOT = Path("D:/mifugo_care")
TRAIN_SCRIPT = ROOT / "ml" / "train_all.py"
MONITOR_SCRIPT = ROOT / "ml" / "monitor_training_loop.py"

def run_training():
    """Run the training script in a separate process."""
    print("=" * 70)
    print("[START] Starting Model Training (20 epochs, targeting 99-100% accuracy)")
    print("=" * 70)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    try:
        # Set environment with UTF-8 encoding
        env = os.environ.copy()
        env['PYTHONIOENCODING'] = 'utf-8'
        
        process = subprocess.Popen(
            [sys.executable, str(TRAIN_SCRIPT)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            bufsize=1,
            cwd=str(ROOT),
            env=env
        )
        
        # Stream output in real-time, decoding manually to handle encoding issues
        decoder = io.TextIOWrapper(process.stdout, encoding='utf-8', errors='replace')
        try:
            for line in decoder:
                # Clean up any problematic characters and print
                try:
                    print(line, end='', flush=True)
                except (UnicodeEncodeError, UnicodeDecodeError):
                    # If we still can't print, replace problematic chars
                    safe_line = line.encode('ascii', errors='replace').decode('ascii', errors='replace')
                    print(safe_line, end='', flush=True)
        finally:
            decoder.close()
        
        process.wait()
        return process.returncode == 0
    except Exception as e:
        print(f"[ERROR] Error running training: {e}")
        import traceback
        traceback.print_exc()
        return False

def run_monitoring():
    """Run the monitoring script in a separate process."""
    # Wait a bit for training to start
    time.sleep(30)  # Wait 30 seconds before first check
    
    try:
        # Set environment with UTF-8 encoding
        env = os.environ.copy()
        env['PYTHONIOENCODING'] = 'utf-8'
        
        process = subprocess.run(
            [sys.executable, str(MONITOR_SCRIPT)],
            encoding='utf-8',
            errors='replace',
            cwd=str(ROOT),
            env=env
        )
        return process.returncode == 0
    except Exception as e:
        print(f"[ERROR] Error running monitoring: {e}")
        return False

def main():
    """Main function to run training and monitoring."""
    print("=" * 70)
    print("[TARGET] Model Training with Auto-Monitoring")
    print("=" * 70)
    print("Configuration:")
    print("  - Epochs: 20")
    print("  - Target Accuracy: 99-100%")
    print("  - Monitoring: Every 5 minutes")
    print("  - Device: GPU (CUDA)" if torch.cuda.is_available() else "  - Device: CPU")
    print("=" * 70)
    print()
    
    # Start monitoring in a separate thread
    monitor_thread = threading.Thread(target=run_monitoring, daemon=True)
    monitor_thread.start()
    
    # Run training in main thread
    training_success = run_training()
    
    if training_success:
        print("\n" + "=" * 70)
        print("[SUCCESS] Training completed successfully!")
        print("=" * 70)
        print("\nWaiting for monitoring to complete model copying...")
        monitor_thread.join(timeout=60)  # Wait up to 1 minute for monitoring to finish
    else:
        print("\n" + "=" * 70)
        print("[ERROR] Training encountered errors. Check logs above.")
        print("=" * 70)
        sys.exit(1)

if __name__ == "__main__":
    main()

