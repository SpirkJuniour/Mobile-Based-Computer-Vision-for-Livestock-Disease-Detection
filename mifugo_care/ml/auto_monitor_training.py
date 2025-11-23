"""Automated training monitor - checks every 5 minutes."""
import time
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
MONITOR_SCRIPT = ROOT / "ml" / "monitor_training.py"

def main():
    print("=" * 60)
    print("Automated Training Monitor")
    print("Checking every 5 minutes...")
    print("Press Ctrl+C to stop")
    print("=" * 60)
    print()
    
    check_count = 0
    
    try:
        while True:
            check_count += 1
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
            
            print(f"[{timestamp}] Check #{check_count}")
            print("-" * 60)
            
            # Run the monitoring script
            result = subprocess.run(
                [sys.executable, str(MONITOR_SCRIPT)],
                cwd=str(ROOT),
                capture_output=False
            )
            
            print()
            print("Next check in 5 minutes...")
            print()
            
            # Wait 5 minutes (300 seconds)
            time.sleep(300)
            
    except KeyboardInterrupt:
        print("\n" + "=" * 60)
        print("Monitoring stopped by user")
        print("=" * 60)

if __name__ == "__main__":
    main()

