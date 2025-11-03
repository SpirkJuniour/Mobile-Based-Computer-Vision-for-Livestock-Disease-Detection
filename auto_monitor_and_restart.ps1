# Automatic Training Monitor with Auto-Restart
# Monitors training every minute and restarts if crashed

$scriptPath = "scripts/train_livestock_model.py"
$logFile = "training_monitor_auto.log"
$maxRestarts = 5
$restartCount = 0

function Write-Log {
    param($message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] $message"
    Write-Host $logMessage
    $logMessage | Out-File -Append $logFile
}

Write-Log "=== AUTO-MONITOR STARTED ==="
Write-Log "Will check every minute and auto-restart if needed"

# Find current training process
$currentPid = $null
$pythonProcs = Get-Process python -EA SilentlyContinue | Where-Object {$_.WorkingSet -gt 100MB}
if($pythonProcs) {
    $currentPid = $pythonProcs[0].Id
    Write-Log "Found existing training process: PID $currentPid"
}

$checkCount = 0
$lastFileCount = 0

while($true) {
    Start-Sleep 60
    $checkCount++
    
    Write-Log "`n========== MINUTE $checkCount CHECK =========="
    
    # Check if process is still running
    if($currentPid) {
        $proc = Get-Process -Id $currentPid -EA SilentlyContinue
        if($proc) {
            $cpuTime = [math]::Round($proc.CPU, 1)
            $memMB = [math]::Round($proc.WorkingSet/1MB, 0)
            Write-Log "[PROCESS] Running - PID: $currentPid | CPU: ${cpuTime}s | RAM: ${memMB}MB"
            
            # Check if making progress
            $files = @(Get-ChildItem training_results -File -EA SilentlyContinue)
            $fileCount = $files.Count
            Write-Log "[FILES] $fileCount files in training_results"
            
            if($fileCount -gt $lastFileCount) {
                Write-Log "[PROGRESS] New files created! Training is progressing"
                $lastFileCount = $fileCount
            }
            
            # Check if model saved (training complete or in progress)
            if(Test-Path "training_results\best_model.pth") {
                $model = Get-Item "training_results\best_model.pth"
                $sizeMB = [math]::Round($model.Length/1MB, 1)
                Write-Log "[MODEL] Saved! Size: ${sizeMB}MB | Last modified: $($model.LastWriteTime.ToString('HH:mm:ss'))"
            }
            
            # Check training log for completion
            if(Test-Path "training_results\training_log.csv") {
                $logLines = Get-Content "training_results\training_log.csv"
                if($logLines.Count -gt 1) {
                    $lastLine = $logLines[-1]
                    Write-Log "[LATEST] $lastLine"
                    
                    # Check if training completed
                    if($logLines.Count -ge 51) {  # Header + 50 epochs
                        Write-Log "=== TRAINING COMPLETED SUCCESSFULLY! ==="
                        Write-Log "Total epochs: $($logLines.Count - 1)"
                        break
                    }
                }
            }
            
            continue
        } else {
            Write-Log "[WARNING] Process $currentPid stopped!"
            $currentPid = $null
        }
    }
    
    # Process not running - check if training completed or crashed
    if(Test-Path "training_results\best_model.pth") {
        $model = Get-Item "training_results\best_model.pth"
        $age = (Get-Date) - $model.LastWriteTime
        
        if($age.TotalMinutes -lt 5) {
            Write-Log "[SUCCESS] Training appears to have completed recently!"
            Write-Log "Model file last modified: $($model.LastWriteTime)"
            
            # Check if metrics.json exists (final output)
            if(Test-Path "training_results\final_metrics.json") {
                Write-Log "[COMPLETE] Final metrics found - training is done!"
                break
            }
        }
    }
    
    # Training crashed or stopped - restart if under limit
    if($restartCount -lt $maxRestarts) {
        $restartCount++
        Write-Log "[RESTART] Attempt $restartCount of $maxRestarts"
        Write-Log "Starting training process..."
        
        # Start new training process
        $job = Start-Process python -ArgumentList $scriptPath -PassThru -WindowStyle Hidden
        $currentPid = $job.Id
        Write-Log "[STARTED] New training process: PID $currentPid"
        
        # Wait a bit for it to initialize
        Start-Sleep 30
        
        # Verify it started
        $proc = Get-Process -Id $currentPid -EA SilentlyContinue
        if($proc) {
            Write-Log "[OK] Process confirmed running"
        } else {
            Write-Log "[ERROR] Failed to start process"
            $currentPid = $null
        }
    } else {
        Write-Log "[FAILED] Max restart attempts ($maxRestarts) reached"
        Write-Log "Please check for errors manually"
        break
    }
}

Write-Log "`n=== MONITORING COMPLETE ==="
Write-Log "Check training_results folder for outputs"
Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

