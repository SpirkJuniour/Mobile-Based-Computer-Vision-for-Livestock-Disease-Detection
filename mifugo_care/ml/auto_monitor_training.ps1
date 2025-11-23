# Automated Training Monitor - Runs every 5 minutes
# Usage: Run this script and it will check training progress every 5 minutes

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$monitorScript = Join-Path $scriptPath "monitor_training.py"

Write-Host "============================================================"
Write-Host "Automated Training Monitor"
Write-Host "Checking every 5 minutes..."
Write-Host "Press Ctrl+C to stop"
Write-Host "============================================================"
Write-Host ""

$checkCount = 0

while ($true) {
    $checkCount++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "[$timestamp] Check #$checkCount"
    Write-Host "----------------------------------------"
    
    # Run the monitoring script
    python $monitorScript
    
    Write-Host ""
    Write-Host "Next check in 5 minutes..."
    Write-Host ""
    
    # Wait 5 minutes (300 seconds)
    Start-Sleep -Seconds 300
}

