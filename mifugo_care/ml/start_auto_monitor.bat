@echo off
REM Start automated training monitor in background
echo Starting automated training monitor...
echo This will check training progress every 5 minutes
echo.
echo To stop monitoring, close this window or press Ctrl+C
echo.

cd /d "%~dp0\.."
python ml\auto_monitor_training.py

pause

