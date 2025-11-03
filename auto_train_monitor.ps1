# Auto Training Monitor - Runs until completion
# Will restart training if it crashes

$currentPID = 3560  # Current training process
$scriptPath = "scripts\train_livestock_model.py"
$logFile = "auto_monitor.log"

function Log {
    param($msg)
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$ts - $msg" | Tee-Object -Append $logFile
}

Log "=== MONITOR STARTED ==="
Log "Monitoring PID: $currentPID"

$restarts = 0
$maxRestarts = 10

while($true) {
    Start-Sleep 60
    
    $time = Get-Date -Format 'HH:mm:ss'
    Log "`n=== CHECK - $time ==="
    
    # Check process
    $p = Get-Process -Id $currentPID -EA SilentlyContinue
    if($p) {
        $cpu = [math]::Round($p.CPU, 1)
        $mem = [math]::Round($p.WorkingSet/1MB, 0)
        Log "[ACTIVE] PID $currentPID | CPU: ${cpu}s | RAM: ${mem}MB"
    } else {
        Log "[DEAD] Process $currentPID not running"
        
        # Check if training completed
        if((Test-Path "training_results\final_metrics.json")) {
            Log "[SUCCESS] Training completed!"
            break
        }
        
        # Restart if under limit
        if($restarts -lt $maxRestarts) {
            $restarts++
            Log "[RESTART] Attempt $restarts/$maxRestarts"
            
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "python"
            $pinfo.Arguments = $scriptPath
            $pinfo.UseShellExecute = $false
            $pinfo.RedirectStandardOutput = $true
            $pinfo.RedirectStandardError = $true
            $pinfo.WorkingDirectory = (Get-Location).Path
            
            $proc = New-Object System.Diagnostics.Process
            $proc.StartInfo = $pinfo
            $proc.Start() | Out-Null
            $currentPID = $proc.Id
            
            Log "[STARTED] New PID: $currentPID"
            Start-Sleep 30
            continue
        } else {
            Log "[FAILED] Max restarts reached"
            break
        }
    }
    
    # Check files
    $files = @(Get-ChildItem training_results -File -EA SilentlyContinue)
    Log "[FILES] $($files.Count) in training_results"
    
    if(Test-Path "training_results\best_model.pth") {
        $model = Get-Item "training_results\best_model.pth"
        $sizeMB = [math]::Round($model.Length/1MB, 1)
        Log "[MODEL] ${sizeMB}MB | Modified: $($model.LastWriteTime.ToString('HH:mm:ss'))"
    }
    
    if(Test-Path "training_results\training_log.csv") {
        $lines = Get-Content "training_results\training_log.csv"
        if($lines.Count -gt 1) {
            $latest = $lines[-1]
            Log "[PROGRESS] $latest"
            
            if($lines.Count -ge 51) {
                Log "[COMPLETE] All 50 epochs done!"
                break
            }
        }
    }
    
    if(Test-Path "training_results\final_metrics.json") {
        Log "[COMPLETE] Final metrics saved - training done!"
        break
    }
}

Log "`n=== MONITORING ENDED ==="
Log "Training results in: training_results\"

