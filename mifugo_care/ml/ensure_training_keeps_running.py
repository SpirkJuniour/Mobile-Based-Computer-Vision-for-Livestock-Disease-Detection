"""Ensure training continues running - restart if it stops."""
import subprocess
import sys
import time
import os
from pathlib import Path
from datetime import datetime

ROOT = Path("D:/mifugo_care")
TRAIN_SCRIPT = ROOT / "ml" / "train_all.py"
MONITOR_SCRIPT = ROOT / "ml" / "monitor_training_loop.py"
LOG_FILE = ROOT / "ml" / "training_watchdog.log"

def log_message(message):
    """Log message to file and console."""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    # Remove emoji and special characters for Windows compatibility
    clean_message = message.encode('ascii', 'ignore').decode('ascii')
    log_entry = f"[{timestamp}] {clean_message}\n"
    print(log_entry.strip())
    try:
        with open(LOG_FILE, 'a', encoding='utf-8', errors='ignore') as f:
            f.write(log_entry)
    except Exception:
        # Fallback to ASCII if UTF-8 fails
        with open(LOG_FILE, 'a', encoding='ascii', errors='ignore') as f:
            f.write(log_entry)

def check_training_active():
    """Check if training is producing results."""
    try:
        # Check for recent training runs
        detect_dirs = sorted((ROOT / "ml" / "runs" / "detect").glob("animal_pathologies*"), 
                           key=lambda x: x.stat().st_mtime, reverse=True)
        classify_dirs = sorted((ROOT / "ml" / "runs" / "classify").glob("cattle diseases*"), 
                              key=lambda x: x.stat().st_mtime, reverse=True)
        
        if not detect_dirs or not classify_dirs:
            return False
        
        latest_detect = detect_dirs[0]
        latest_classify = classify_dirs[0]
        
        # Check if results.csv exists and was modified recently (within last 10 minutes)
        detect_results = latest_detect / "results.csv"
        classify_results = latest_classify / "results.csv"
        
        if detect_results.exists():
            time_since_mod = time.time() - detect_results.stat().st_mtime
            if time_since_mod < 600:  # Modified within last 10 minutes
                return True
        
        if classify_results.exists():
            time_since_mod = time.time() - classify_results.stat().st_mtime
            if time_since_mod < 600:  # Modified within last 10 minutes
                return True
        
        # Check if training directories are being actively written to
        time_since_detect = time.time() - latest_detect.stat().st_mtime
        time_since_classify = time.time() - latest_classify.stat().st_mtime
        
        # If directories were modified within last 5 minutes, training is likely active
        return time_since_detect < 300 or time_since_classify < 300
    except Exception as e:
        log_message(f"Error checking training status: {e}")
        return False

def run_training_with_restart():
    """Run training and restart if it fails."""
    max_restarts = 5
    restart_count = 0
    
    while restart_count < max_restarts:
        try:
            log_message(f"Starting training (attempt {restart_count + 1}/{max_restarts})...")
            
            process = subprocess.Popen(
                [sys.executable, str(TRAIN_SCRIPT)],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                cwd=str(ROOT)
            )
            
            log_message(f"Training process started (PID: {process.pid})")
            
            # Monitor process and stream output
            for line in process.stdout:
                log_message(f"TRAIN: {line.strip()}")
            
            return_code = process.wait()
            
            if return_code == 0:
                log_message("✅ Training completed successfully!")
                return True
            else:
                log_message(f"⚠️ Training exited with code {return_code}")
                restart_count += 1
                if restart_count < max_restarts:
                    log_message(f"Restarting training in 30 seconds...")
                    time.sleep(30)
                else:
                    log_message("❌ Max restart attempts reached. Stopping.")
                    return False
                    
        except KeyboardInterrupt:
            log_message("Training interrupted by user")
            return False
        except Exception as e:
            log_message(f"❌ Error running training: {e}")
            restart_count += 1
            if restart_count < max_restarts:
                log_message(f"Restarting training in 30 seconds...")
                time.sleep(30)
            else:
                log_message("❌ Max restart attempts reached. Stopping.")
                return False
    
    return False

def main():
    """Main watchdog function."""
    log_message("=" * 70)
    log_message("🛡️ Training Watchdog Started")
    log_message("=" * 70)
    log_message("This script ensures training continues running")
    log_message("It will restart training if it stops unexpectedly")
    log_message("=" * 70)
    
    # Check if training is already active
    if check_training_active():
        log_message("✅ Training appears to be already running")
        log_message("Monitoring existing training process...")
        
        # Just monitor - don't start new training
        try:
            process = subprocess.run(
                [sys.executable, str(MONITOR_SCRIPT)],
                cwd=str(ROOT)
            )
        except KeyboardInterrupt:
            log_message("Monitoring interrupted by user")
    else:
        log_message("Starting new training session...")
        run_training_with_restart()
        
        # After training, run monitoring to copy models
        log_message("Training finished. Starting model monitoring...")
        try:
            subprocess.run(
                [sys.executable, str(MONITOR_SCRIPT)],
                cwd=str(ROOT)
            )
        except Exception as e:
            log_message(f"Error in monitoring: {e}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log_message("\nWatchdog stopped by user")
        sys.exit(0)
    except Exception as e:
        log_message(f"Fatal error: {e}")
        sys.exit(1)

