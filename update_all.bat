@echo off
echo Starting AI News Collector and GitHub update process...
PowerShell -ExecutionPolicy Bypass -File "%~dp0\update_all.ps1"
pause
