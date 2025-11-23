@echo off
setlocal enabledelayedexpansion

REM Run from project root
pushd D:\mifugo_care

where python >nul 2>&1
if errorlevel 1 (
  echo Python is not installed or not on PATH. Install Python 3.10+ first.
  echo Example: winget install Python.Python.3.12
  popd
  exit /b 1
)

if not exist .venv (
  echo Creating virtual environment ...
  python -m venv .venv
)

call .venv\Scripts\activate.bat

python -m pip install --upgrade pip
pip install -r ml\requirements.txt

echo If you have an NVIDIA GPU and want CUDA builds of PyTorch, you can run:
echo   pip uninstall -y torch torchvision
echo   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124

python ml\train_all.py

popd
endlocal

