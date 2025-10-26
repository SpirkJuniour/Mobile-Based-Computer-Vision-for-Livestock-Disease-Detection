#!/usr/bin/env python3
"""
Check training status and display progress
"""

from pathlib import Path
import time
import os

def check_training_status():
    """Check and display training status"""
    output_dir = Path(__file__).parent / "training_outputs"
    
    print("=" * 70)
    print("Training Status Check")
    print("=" * 70)
    
    if not output_dir.exists():
        print("\n[STATUS] Training outputs directory not found")
        print("Training may not have started yet.")
        return
    
    print(f"\n[OK] Training outputs directory: {output_dir}")
    
    # Check for files
    files = list(output_dir.glob("*"))
    
    if not files:
        print("\n[STATUS] No output files yet")
        print("Training is likely loading data or in early stages...")
        return
    
    print(f"\n[OK] Found {len(files)} file(s):\n")
    
    for file in sorted(files):
        size = file.stat().st_size
        size_mb = size / (1024 * 1024)
        modified = time.ctime(file.stat().st_mtime)
        
        if size > 1024 * 1024:
            size_str = f"{size_mb:.2f} MB"
        elif size > 1024:
            size_str = f"{size / 1024:.2f} KB"
        else:
            size_str = f"{size} bytes"
        
        print(f"   - {file.name}")
        print(f"     Size: {size_str}")
        print(f"     Modified: {modified}\n")
    
    # Check training history
    history_file = output_dir / "training_history.csv"
    if history_file.exists():
        print("[*] Training history found - Reading progress...")
        try:
            with open(history_file, 'r') as f:
                lines = f.readlines()
                if len(lines) > 1:
                    print(f"    Completed epochs: {len(lines) - 1}")
                    print(f"\n    Latest entries:")
                    for line in lines[-min(3, len(lines)):]:
                        print(f"      {line.strip()}")
        except Exception as e:
            print(f"    Error reading history: {e}")
    
    # Check for model files
    model_file = output_dir / "livestock_disease_model.h5"
    tflite_file = output_dir / "livestock_disease_model.tflite"
    
    if model_file.exists():
        print(f"\n[OK] Model trained successfully!")
        print(f"     Model file: {model_file}")
    
    if tflite_file.exists():
        print(f"[OK] TFLite model created!")
        print(f"     TFLite file: {tflite_file}")
    
    print("\n" + "=" * 70)
    
    # Check if Python process is running
    try:
        import psutil
        python_processes = []
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                if proc.info['name'] and 'python' in proc.info['name'].lower():
                    cmdline = proc.info.get('cmdline', [])
                    if cmdline and any('train' in str(arg).lower() for arg in cmdline):
                        python_processes.append(proc.info['pid'])
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        
        if python_processes:
            print(f"\n[INFO] Training process(es) running: PID {python_processes}")
        else:
            print(f"\n[INFO] No active training process detected")
    except ImportError:
        print("\n[INFO] Install psutil to check process status: pip install psutil")

if __name__ == "__main__":
    check_training_status()

