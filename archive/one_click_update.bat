@echo off
TITLE AI News Daily Updater
echo AI News Daily - One-Step Update Process
echo =======================================
echo.

REM Step 1: Collect new articles
echo Step 1: Collecting new AI and ML articles...
python ai_news_collector.py

REM Step 2: Deploy to GitHub
echo.
echo Step 2: Preparing files for GitHub Pages...
python deploy_to_github.py

REM Step 3: Navigate to docs and push to GitHub
echo.
echo Step 3: Pushing changes to GitHub...
cd docs

REM Initialize git if needed
git init

REM Add all files
git add .

REM Set date for commit message
FOR /F "tokens=2 delims==" %%I IN ('wmic os get localdatetime /format:list') DO SET datetime=%%I
SET date=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
SET time=%datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%

REM Commit changes
git commit -m "Update AI News Daily: Latest articles collected on %date% %time%"

REM Add remote if needed (if one push fails, we try the other)
git remote add origin https://github.com/steviesimsii/AiNewsDaily.git 2>nul
git remote set-url origin https://github.com/steviesimsii/AiNewsDaily.git 2>nul

REM Push to GitHub - try both master and main
git push -u origin main -f
if %ERRORLEVEL% NEQ 0 git push -u origin master -f

cd ..

echo.
echo Process completed!
echo Your website should be updated at: https://steviesimsii.github.io/AiNewsDaily/
echo Note: It may take a few minutes for GitHub Pages to update with the latest changes.
echo.
pause
