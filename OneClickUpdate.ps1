# OneClickUpdate.ps1
# This script performs all necessary actions to update the AI News Daily website:
# 1. Runs the news collector to gather fresh news
# 2. Deploys the web app to the docs directory
# 3. Optionally commits and pushes changes to GitHub

param(
    [switch]$PushToGitHub = $false,
    [string]$CommitMessage = "Update AI News Daily website with fresh content"
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  AI NEWS DAILY - ONE CLICK UPDATE" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command was successful
function Check-LastExitCode {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Last command failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Step 1: Run the news collector
Write-Host "Step 1: Collecting fresh AI news..." -ForegroundColor Green
python ai_news_collector.py
Check-LastExitCode
Write-Host "News collection completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Deploy the web app to docs
Write-Host "Step 2: Deploying web app to docs directory..." -ForegroundColor Green
python deploy_to_github.py
Check-LastExitCode
Write-Host "Web app deployment completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 3: Optionally commit and push changes to GitHub
if ($PushToGitHub) {
    Write-Host "Step 3: Committing and pushing changes to GitHub..." -ForegroundColor Green
    git add .
    Check-LastExitCode
    git commit -m $CommitMessage
    Check-LastExitCode
    git push
    Check-LastExitCode
    Write-Host "Changes pushed to GitHub successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Check GitHub Pages configuration
    Write-Host "Step 4: Checking GitHub Pages configuration..." -ForegroundColor Green
    python check_github_pages.py
    Write-Host ""
} else {
    Write-Host "NOTICE: Changes have not been pushed to GitHub." -ForegroundColor Yellow
    Write-Host "To push changes, run this script with the -PushToGitHub switch:" -ForegroundColor Yellow
    Write-Host "  .\OneClickUpdate.ps1 -PushToGitHub" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  UPDATE PROCESS COMPLETED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
