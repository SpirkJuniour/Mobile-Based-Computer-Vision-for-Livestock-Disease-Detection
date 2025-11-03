# Training Monitor Script
# Checks every minute if training is running and using GPU

$pidToMonitor = 23496
$outputFile = "training_monitor.log"

Write-Host "Starting training monitor for PID $pidToMonitor"
Write-Host "Logging to: $outputFile"
Write-Host "Press Ctrl+C to stop monitoring`n"

for($min=1; $min -le 120; $min++) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $output = "`n========== MINUTE $min - $timestamp =========="
    
    # Check GPU
    $gpu = nvidia-smi --query-gpu=memory.used,utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>$null
    if($gpu) {
        $g = $gpu.Split(',')
        $output += "`n[GPU] VRAM: $($g[0].Trim())MB | Usage: $($g[1].Trim())% | Temp: $($g[2].Trim())C"
    } else {
        $output += "`n[GPU] Not detected!"
    }
    
    # Check process
    $p = Get-Process -Id $pidToMonitor -ErrorAction SilentlyContinue
    if($p) {
        $output += "`n[TRAIN] RUNNING - CPU: $([math]::Round($p.CPU,1))s | RAM: $([math]::Round($p.WorkingSet/1MB,0))MB"
    } else {
        $output += "`n[TRAIN] STOPPED - Process $pidToMonitor died!"
        Write-Host $output
        $output | Out-File -Append $outputFile
        break
    }
    
    # Check files
    $files = @(Get-ChildItem training_results -File -ErrorAction SilentlyContinue)
    $output += "`n[FILES] $($files.Count) files in training_results"
    
    # Check for model
    if(Test-Path "training_results\best_model.pth") {
        $m = Get-Item "training_results\best_model.pth"
        $output += "`n[MODEL] Saved! Size: $([math]::Round($m.Length/1MB,1))MB at $($m.LastWriteTime.ToString('HH:mm:ss'))"
    }
    
    # Check training log
    if(Test-Path "training_results\training_log.csv") {
        $log = Get-Content "training_results\training_log.csv" -Tail 1
        if($log -and $log -ne "Epoch,Train_Loss,Train_Acc,Val_Loss,Val_Acc") {
            $output += "`n[PROGRESS] Latest: $log"
        }
    }
    
    Write-Host $output
    $output | Out-File -Append $outputFile
    
    if($min -lt 120) {
        Start-Sleep 60
    }
}

Write-Host "`nMonitoring complete or stopped."

