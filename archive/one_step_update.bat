@echo off
TITLE AI News Daily - One-Click Update

echo AI News Daily - One-Click Update
echo ==============================
echo.

REM Step 1: Run the collector in automatic mode
echo Step 1: Collecting new articles...
echo 1 | call run_collector.bat

REM Step 2: Deploy to GitHub
echo.
echo Step 2: Deploying to GitHub...
python deploy_to_github.py

REM Step 3: Update GitHub
echo.
echo Step 3: Pushing to GitHub...
cd web_app
call ..\update_github.ps1
cd ..

echo.
echo Done! Your website should be updated shortly at:
echo https://steviesimsii.github.io/AiNewsDaily/
echo.
pause
