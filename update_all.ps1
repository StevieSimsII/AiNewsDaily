# One-step process to collect AI/ML news and update GitHub
# Created: May 15, 2025

# Force display of errors for debugging
$ErrorActionPreference = "Continue"
$DebugPreference = "Continue"

Write-Host "AI News Daily - One-Step Update Process" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Run the collector to get new articles
Write-Host "Step 1: Collecting new AI and ML articles..." -ForegroundColor Green
cd $PSScriptRoot

# Run the Python collector directly (instead of through the batch menu)
python ai_news_collector.py

# Step 2: Deploy to GitHub pages
Write-Host "`nStep 2: Preparing files for GitHub Pages..." -ForegroundColor Green
python deploy_to_github.py

# Step 3: Push to GitHub
Write-Host "`nStep 3: Pushing changes to GitHub..." -ForegroundColor Green

# Navigate to the docs directory which contains the website
cd "$PSScriptRoot\docs"

# Initialize git if needed
if (-not (Test-Path -Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
}

# Add all files
Write-Host "Adding files to git..." -ForegroundColor Yellow
git add .

# Commit changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Update AI News Daily: Latest articles collected on $date"

# Check if remote exists, add if not
$remoteExists = git remote -v | Select-String -Pattern "origin"
if (-not $remoteExists) {
    Write-Host "Adding remote origin..." -ForegroundColor Yellow
    git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
}

# Push to GitHub - using 'main' branch which is standard for new repos
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin main -f

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your website should be updated at: https://steviesimsii.github.io/AiNewsDaily/" -ForegroundColor Cyan
Write-Host "Note: It may take a few minutes for GitHub Pages to update with the latest changes." -ForegroundColor Yellow
