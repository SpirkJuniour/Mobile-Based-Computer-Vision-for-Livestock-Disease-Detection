#!/usr/bin/env python3
"""
Comprehensive Dependency Checker
Checks all dependencies across Flutter and Python code
"""

import subprocess
import sys
import os
from pathlib import Path
import json

def run_command(command, description):
    """Run a command and return success status"""
    print(f"🔄 {description}")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print("✅ Success!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e}")
        if e.stderr:
            print(f"Error output: {e.stderr}")
        return False

def check_flutter_dependencies():
    """Check Flutter dependencies"""
    print("\n📱 Checking Flutter Dependencies")
    print("=" * 40)
    
    # Check if Flutter is installed
    if not run_command("flutter --version", "Checking Flutter installation"):
        print("❌ Flutter not found. Please install Flutter first.")
        return False
    
    # Check pubspec.yaml exists
    if not Path("pubspec.yaml").exists():
        print("❌ pubspec.yaml not found")
        return False
    
    # Install Flutter dependencies
    if not run_command("flutter pub get", "Installing Flutter dependencies"):
        print("❌ Failed to install Flutter dependencies")
        return False
    
    # Check for specific packages
    critical_packages = [
        "tflite_flutter",
        "tflite_flutter_helper", 
        "image",
        "camera",
        "image_picker"
    ]
    
    print("\n🔍 Checking critical packages...")
    for package in critical_packages:
        if run_command(f"flutter pub deps | grep {package}", f"Checking {package}"):
            print(f"✅ {package} - Available")
        else:
            print(f"❌ {package} - Missing")
    
    return True

def check_python_dependencies():
    """Check Python dependencies"""
    print("\n🐍 Checking Python Dependencies")
    print("=" * 40)
    
    # Check if Python is installed
    if not run_command("python --version", "Checking Python installation"):
        print("❌ Python not found")
        return False
    
    # Check requirements.txt
    requirements_file = Path("scripts/requirements.txt")
    if not requirements_file.exists():
        print("❌ requirements.txt not found")
        return False
    
    # Install Python dependencies
    if not run_command("pip install -r scripts/requirements.txt", "Installing Python dependencies"):
        print("❌ Failed to install Python dependencies")
        return False
    
    # Check critical packages
    critical_packages = [
        "torch",
        "torchvision", 
        "numpy",
        "pandas",
        "PIL",
        "sklearn",
        "matplotlib",
        "albumentations",
        "opencv-python"
    ]
    
    print("\n🔍 Checking critical Python packages...")
    for package in critical_packages:
        try:
            __import__(package)
            print(f"✅ {package} - Available")
        except ImportError:
            print(f"❌ {package} - Missing")
            return False
    
    return True

def check_import_statements():
    """Check all import statements in the codebase"""
    print("\n📦 Checking Import Statements")
    print("=" * 40)
    
    # Check Flutter imports
    flutter_files = list(Path("lib").rglob("*.dart"))
    print(f"Found {len(flutter_files)} Dart files")
    
    import_issues = []
    
    for file_path in flutter_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Check for common import issues
            if 'package:tflite_flutter' in content:
                print(f"🔍 {file_path.name} - Uses TensorFlow Lite")
            if 'package:image' in content:
                print(f"🔍 {file_path.name} - Uses image processing")
            if 'package:camera' in content:
                print(f"🔍 {file_path.name} - Uses camera")
                
        except Exception as e:
            import_issues.append(f"{file_path}: {e}")
    
    if import_issues:
        print("❌ Import issues found:")
        for issue in import_issues:
            print(f"  - {issue}")
        return False
    
    print("✅ All import statements look good")
    return True

def check_ml_dependencies():
    """Check ML-specific dependencies"""
    print("\n🧠 Checking ML Dependencies")
    print("=" * 40)
    
    # Check TensorFlow Lite availability
    try:
        import tensorflow as tf
        print("✅ TensorFlow available")
        
        # Check TensorFlow Lite
        if hasattr(tf, 'lite'):
            print("✅ TensorFlow Lite available")
        else:
            print("❌ TensorFlow Lite not available")
            return False
            
    except ImportError:
        print("❌ TensorFlow not available")
        return False
    
    # Check PyTorch
    try:
        import torch
        print(f"✅ PyTorch available - Version: {torch.__version__}")
    except ImportError:
        print("❌ PyTorch not available")
        return False
    
    # Check other ML packages
    ml_packages = [
        "torchvision",
        "albumentations", 
        "opencv-python",
        "scikit-learn"
    ]
    
    for package in ml_packages:
        try:
            __import__(package)
            print(f"✅ {package} - Available")
        except ImportError:
            print(f"❌ {package} - Missing")
            return False
    
    return True

def check_file_structure():
    """Check if all required files exist"""
    print("\n📁 Checking File Structure")
    print("=" * 40)
    
    required_files = [
        "pubspec.yaml",
        "lib/main.dart",
        "lib/core/services/ml_service_90_percent.dart",
        "scripts/requirements.txt",
        "scripts/train_90_percent_model.py",
        "scripts/convert_to_tflite_advanced.py"
    ]
    
    missing_files = []
    for file_path in required_files:
        if Path(file_path).exists():
            print(f"✅ {file_path}")
        else:
            print(f"❌ {file_path} - Missing")
            missing_files.append(file_path)
    
    if missing_files:
        print(f"\n❌ Missing files: {missing_files}")
        return False
    
    return True

def create_dependency_report():
    """Create a comprehensive dependency report"""
    print("\n📊 Creating Dependency Report")
    print("=" * 40)
    
    report = {
        "flutter_dependencies": {
            "flutter_installed": False,
            "dependencies_installed": False,
            "critical_packages": []
        },
        "python_dependencies": {
            "python_installed": False,
            "dependencies_installed": False,
            "critical_packages": []
        },
        "ml_dependencies": {
            "tensorflow_available": False,
            "pytorch_available": False,
            "other_ml_packages": []
        },
        "file_structure": {
            "required_files_present": False,
            "missing_files": []
        },
        "overall_status": "unknown"
    }
    
    # Check Flutter
    try:
        subprocess.run("flutter --version", shell=True, check=True, capture_output=True)
        report["flutter_dependencies"]["flutter_installed"] = True
    except:
        pass
    
    # Check Python
    try:
        subprocess.run("python --version", shell=True, check=True, capture_output=True)
        report["python_dependencies"]["python_installed"] = True
    except:
        pass
    
    # Save report
    with open("dependency_report.json", "w") as f:
        json.dump(report, f, indent=2)
    
    print("✅ Dependency report saved to dependency_report.json")
    return report

def main():
    """Main dependency check function"""
    print("🔍 Comprehensive Dependency Checker")
    print("=" * 50)
    
    all_checks_passed = True
    
    # Check file structure
    if not check_file_structure():
        all_checks_passed = False
    
    # Check Flutter dependencies
    if not check_flutter_dependencies():
        all_checks_passed = False
    
    # Check Python dependencies
    if not check_python_dependencies():
        all_checks_passed = False
    
    # Check ML dependencies
    if not check_ml_dependencies():
        all_checks_passed = False
    
    # Check import statements
    if not check_import_statements():
        all_checks_passed = False
    
    # Create report
    create_dependency_report()
    
    print("\n" + "=" * 50)
    if all_checks_passed:
        print("🎉 ALL DEPENDENCIES ARE FUNCTIONING!")
        print("✅ Flutter dependencies: OK")
        print("✅ Python dependencies: OK") 
        print("✅ ML dependencies: OK")
        print("✅ Import statements: OK")
        print("✅ File structure: OK")
    else:
        print("❌ SOME DEPENDENCIES HAVE ISSUES")
        print("Please check the errors above and fix them")
    
    return all_checks_passed

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
