# PowerShell script to keep training running continuously
# This will restart training if it stops

$ErrorActionPreference = "Continue"
$LogFile = "D:\mifugo_care\ml\training_watchdog.log"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

Write-Log "============================================================"
Write-Log "🛡️ Training Watchdog Started (PowerShell)"
Write-Log "============================================================"
Write-Log "This will keep training running and restart if needed"
Write-Log "Press Ctrl+C to stop"
Write-Log "============================================================"

Set-Location "D:\mifugo_care"

$MaxRestarts = 5
$RestartCount = 0

while ($RestartCount -lt $MaxRestarts) {
    try {
        Write-Log "Starting training (attempt $($RestartCount + 1)/$MaxRestarts)..."
        
        # Start training in background
        $TrainingJob = Start-Job -ScriptBlock {
            Set-Location "D:\mifugo_care"
            python ml\train_all.py 2>&1
        }
        
        Write-Log "Training job started (ID: $($TrainingJob.Id))"
        
        # Monitor the job
        $LastOutput = Get-Date
        while ($TrainingJob.State -eq "Running") {
            $Output = Receive-Job -Job $TrainingJob
            if ($Output) {
                foreach ($Line in $Output) {
                    Write-Log "TRAIN: $Line"
                }
                $LastOutput = Get-Date
            }
            
            # Check if job is still running every 30 seconds
            Start-Sleep -Seconds 30
            
            # If no output for 10 minutes, something might be wrong
            if (((Get-Date) - $LastOutput).TotalMinutes -gt 10) {
                Write-Log "⚠️ No output for 10 minutes. Checking training status..."
                # Check if training is actually producing results
                $ResultsExist = Test-Path "ml\runs\detect\*\results.csv" -ErrorAction SilentlyContinue
                if (-not $ResultsExist) {
                    Write-Log "⚠️ No results found. Training may have stalled."
                }
            }
        }
        
        # Job finished
        $FinalOutput = Receive-Job -Job $TrainingJob
        Remove-Job -Job $TrainingJob
        
        if ($FinalOutput) {
            foreach ($Line in $FinalOutput) {
                Write-Log "TRAIN: $Line"
            }
        }
        
        Write-Log "✅ Training job completed"
        break
        
    } catch {
        Write-Log "❌ Error: $_"
        $RestartCount++
        
        if ($RestartCount -lt $MaxRestarts) {
            Write-Log "Restarting in 30 seconds..."
            Start-Sleep -Seconds 30
        } else {
            Write-Log "❌ Max restart attempts reached"
            break
        }
    }
}

Write-Log "============================================================"
Write-Log "Training watchdog finished"
Write-Log "============================================================"

