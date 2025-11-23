param(
	[switch]$Reinstall
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Ensure-Python {
	try {
		$pyVersion = (& python --version) 2>$null
		if (-not $pyVersion) { throw "Python not found" }
		Write-Host "Found $pyVersion"
	} catch {
		Write-Error "Python is not installed or not on PATH. Install Python 3.10+ then rerun:`n  winget install Python.Python.3.12"
		exit 1
	}
}

function New-Venv {
	if ($Reinstall -and (Test-Path ".venv")) {
		Write-Host "Removing existing venv due to -Reinstall ..."
		Remove-Item -Recurse -Force ".venv"
	}
	if (-not (Test-Path ".venv")) {
		Write-Host "Creating virtual environment ..."
		python -m venv .venv
	}
	$activate = Join-Path ".venv" "Scripts" "Activate.ps1"
	if (-not (Test-Path $activate)) {
		Write-Error "Failed to create venv. Ensure Python is correctly installed."
		exit 1
	}
	. $activate
}

function Install-Requirements {
	Write-Host "Upgrading pip ..."
	python -m pip install --upgrade pip

	Write-Host "Installing dependencies from ml/requirements.txt ..."
	pip install -r ml/requirements.txt

	Write-Host "If you have an NVIDIA GPU and want CUDA builds of PyTorch, you can run:"
	Write-Host "  pip uninstall -y torch torchvision"
	Write-Host "  pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124"
}

function Train-All {
	Write-Host "Starting training ..."
	python ml/train_all.py
}

Push-Location "D:/mifugo_care"
try {
	Ensure-Python
	New-Venv
	Install-Requirements
	Train-All
} finally {
	Pop-Location
}

