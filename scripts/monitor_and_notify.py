#!/usr/bin/env python3
"""
Training Monitor with Notifications
Monitors training progress and notifies when complete
"""

from pathlib import Path
import time
import os
import sys

def send_notification(title, message):
    """Send a desktop notification"""
    try:
        # Windows notification
        if sys.platform == 'win32':
            from win10toast import ToastNotifier
            toaster = ToastNotifier()
            toaster.show_toast(title, message, duration=10, threaded=True)
    except ImportError:
        print(f"\n[NOTIFICATION] {title}: {message}")
        print("Install win10toast for desktop notifications: pip install win10toast")
    except Exception as e:
        print(f"[INFO] Notification: {title} - {message}")

def check_training_complete(output_dir):
    """Check if training has completed"""
    model_file = output_dir / "livestock_disease_model.h5"
    tflite_file = output_dir / "livestock_disease_model.tflite"
    metadata_file = output_dir / "model_metadata.json"
    
    return model_file.exists() and tflite_file.exists() and metadata_file.exists()

def get_training_status(output_dir):
    """Get current training status"""
    history_file = output_dir / "training_history.csv"
    
    status = {
        'is_running': False,
        'epochs_completed': 0,
        'current_accuracy': 0.0,
        'current_loss': 0.0,
        'best_accuracy': 0.0
    }
    
    if history_file.exists():
        try:
            with open(history_file, 'r') as f:
                lines = f.readlines()
                if len(lines) > 1:
                    status['epochs_completed'] = len(lines) - 1
                    
                    # Parse last epoch
                    last_line = lines[-1].strip().split(',')
                    if len(last_line) >= 3:
                        try:
                            status['current_accuracy'] = float(last_line[1]) * 100
                            status['current_loss'] = float(last_line[2])
                        except:
                            pass
                    
                    # Find best accuracy
                    for line in lines[1:]:
                        parts = line.strip().split(',')
                        if len(parts) >= 2:
                            try:
                                acc = float(parts[1]) * 100
                                if acc > status['best_accuracy']:
                                    status['best_accuracy'] = acc
                            except:
                                pass
        except Exception as e:
            print(f"[WARN] Error reading history: {e}")
    
    return status

def monitor_training(check_interval=30, max_wait_minutes=180):
    """Monitor training progress and notify when complete"""
    output_dir = Path(__file__).parent / "training_outputs"
    
    print("=" * 70)
    print("Training Monitor Started")
    print("=" * 70)
    print(f"Checking every {check_interval} seconds")
    print(f"Max wait time: {max_wait_minutes} minutes")
    print("\nPress Ctrl+C to stop monitoring (training will continue)\n")
    
    start_time = time.time()
    last_epoch_count = 0
    
    try:
        while True:
            elapsed_minutes = (time.time() - start_time) / 60
            
            if elapsed_minutes > max_wait_minutes:
                print(f"\n[TIMEOUT] Max wait time reached ({max_wait_minutes} minutes)")
                send_notification(
                    "Training Monitor Timeout",
                    f"Stopped monitoring after {max_wait_minutes} minutes. Check manually."
                )
                break
            
            # Check if complete
            if check_training_complete(output_dir):
                print("\n" + "=" * 70)
                print("[SUCCESS] Training Complete!")
                print("=" * 70)
                
                status = get_training_status(output_dir)
                message = (f"Training finished!\n"
                          f"Final Accuracy: {status['best_accuracy']:.2f}%\n"
                          f"Epochs: {status['epochs_completed']}")
                
                send_notification("Training Complete!", message)
                
                print(f"\n[*] Final Results:")
                print(f"    Epochs: {status['epochs_completed']}")
                print(f"    Best Accuracy: {status['best_accuracy']:.2f}%")
                print(f"\n[*] Output files in: {output_dir}")
                print(f"    - livestock_disease_model.tflite (for Flutter app)")
                print(f"    - model_metadata.json")
                print(f"    - confusion_matrix.png")
                break
            
            # Check progress
            status = get_training_status(output_dir)
            
            if status['epochs_completed'] > last_epoch_count:
                print(f"\n[{time.strftime('%H:%M:%S')}] Progress Update:")
                print(f"    Epoch: {status['epochs_completed']}")
                print(f"    Current Accuracy: {status['current_accuracy']:.2f}%")
                print(f"    Current Loss: {status['current_loss']:.4f}")
                print(f"    Best Accuracy: {status['best_accuracy']:.2f}%")
                print(f"    Elapsed: {elapsed_minutes:.1f} min")
                
                last_epoch_count = status['epochs_completed']
                
                # Notify on milestones
                if status['epochs_completed'] % 10 == 0:
                    send_notification(
                        f"Training Progress - Epoch {status['epochs_completed']}",
                        f"Accuracy: {status['best_accuracy']:.2f}%"
                    )
            
            time.sleep(check_interval)
    
    except KeyboardInterrupt:
        print("\n\n[INFO] Monitoring stopped by user")
        print("[INFO] Training continues in background")

def main():
    """Main monitoring function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Monitor model training')
    parser.add_argument('--interval', type=int, default=30,
                       help='Check interval in seconds (default: 30)')
    parser.add_argument('--max-wait', type=int, default=180,
                       help='Maximum wait time in minutes (default: 180)')
    
    args = parser.parse_args()
    
    monitor_training(check_interval=args.interval, max_wait_minutes=args.max_wait)

if __name__ == "__main__":
    main()

