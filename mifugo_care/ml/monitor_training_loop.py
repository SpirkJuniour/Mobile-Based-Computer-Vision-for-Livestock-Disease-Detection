"""Monitor training progress every 5 minutes until completion."""
import time
import subprocess
import sys
import io
from pathlib import Path
from datetime import datetime

# Fix Windows console encoding for emojis
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

ROOT = Path("D:/mifugo_care")
MONITOR_SCRIPT = ROOT / "ml" / "monitor_training.py"
COPY_SCRIPT = ROOT / "ml" / "copy_models_to_flutter.py"

def run_monitor():
    """Run the monitoring script and return True if training is complete."""
    try:
        result = subprocess.run(
            [sys.executable, str(MONITOR_SCRIPT)],
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace',
            cwd=str(ROOT)
        )
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        
        # Check if training is complete (models ready)
        return "[SUCCESS] All models ready" in result.stdout or "All models ready and integrated" in result.stdout
    except Exception as e:
        print(f"Error running monitor: {e}")
        return False

def copy_models():
    """Copy models to Flutter assets."""
    try:
        result = subprocess.run(
            [sys.executable, str(COPY_SCRIPT)],
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace',
            cwd=str(ROOT)
        )
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        return "All models copied successfully" in result.stdout
    except Exception as e:
        print(f"Error copying models: {e}")
        return False

def main():
    """Main monitoring loop - checks every 5 minutes."""
    print("=" * 70)
    print("[MONITOR] Training Monitor - Checking every 5 minutes")
    print("=" * 70)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("Press Ctrl+C to stop monitoring\n")
    
    check_count = 0
    models_copied = False
    
    try:
        while True:
            check_count += 1
            print(f"\n{'='*70}")
            print(f"Check #{check_count} - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"{'='*70}\n")
            
            training_complete = run_monitor()
            
            if training_complete:
                if not models_copied:
                    print("\n" + "="*70)
                    print("[SUCCESS] Training complete! Copying models to Flutter assets...")
                    print("="*70 + "\n")
                    if copy_models():
                        models_copied = True
                        print("\n" + "="*70)
                        print("[SUCCESS] SUCCESS! Models are ready and integrated!")
                        print("="*70)
                        print("\nNext steps:")
                        print("1. Run: flutter clean && flutter pub get")
                        print("2. Test the app with camera integration")
                        print("3. Verify disease detection is working")
                        print("="*70)
                        break
                else:
                    # Models already copied, just confirm
                    print("\n[SUCCESS] Training complete and models are already integrated!")
                    break
            
            if not training_complete:
                print(f"\n[WAIT] Training in progress... Next check in 5 minutes")
                print(f"   (Press Ctrl+C to stop monitoring)")
            
            # Wait 5 minutes (300 seconds)
            time.sleep(300)
            
    except KeyboardInterrupt:
        print("\n\n" + "="*70)
        print("Monitoring stopped by user")
        print(f"Total checks performed: {check_count}")
        print("="*70)
        sys.exit(0)
    except Exception as e:
        print(f"\n\n[ERROR] Error in monitoring loop: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

