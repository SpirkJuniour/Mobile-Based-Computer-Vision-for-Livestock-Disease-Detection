@echo off
REM Batch script to run training with monitoring on Windows

echo ============================================================
echo Starting Model Training with Auto-Monitoring
echo ============================================================
echo.
echo Configuration:
echo   - Epochs: 50
echo   - Target Accuracy: 99-100%%
echo   - Monitoring: Every 5 minutes
echo ============================================================
echo.

cd /d D:\mifugo_care

python ml\train_and_monitor.py

echo.
echo ============================================================
echo Training process completed!
echo ============================================================
pause

