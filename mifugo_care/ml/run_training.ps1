# PowerShell script to run training with monitoring
# This script runs the training and monitors progress every 5 minutes

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "🚀 Starting Model Training with Auto-Monitoring" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  - Epochs: 50" -ForegroundColor White
Write-Host "  - Target Accuracy: 99-100%" -ForegroundColor White
Write-Host "  - Monitoring: Every 5 minutes" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Change to project directory
Set-Location "D:\mifugo_care"

# Run training with monitoring
python ml/train_and_monitor.py

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Training process completed!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

