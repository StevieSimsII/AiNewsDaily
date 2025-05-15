# Deploy to GitHub master branch
# Run this script after making changes to push them to GitHub

Write-Host "AI News Collector - Master Branch Deployment" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Make sure we're in the right directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Step 1: Run the collector to get latest news
Write-Host "Step 1: Collecting new AI and ML articles..." -ForegroundColor Green
python ai_news_collector.py

# Step 2: Deploy to docs
Write-Host "`nStep 2: Deploying to docs folder..." -ForegroundColor Green
python deploy_to_github.py

# Step 3: Clean up any problematic Git files
Write-Host "`nStep 3: Cleaning up repository structure..." -ForegroundColor Green

# Remove nested .git directories
$docsGitDir = Join-Path $scriptPath "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Removing .git directory from docs folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir
}

# Check for and remove .gitmodules file if it exists
$gitmodulesFile = Join-Path $scriptPath ".gitmodules"
if (Test-Path $gitmodulesFile) {
    Write-Host "Removing .gitmodules file..." -ForegroundColor Yellow
    Remove-Item -Force $gitmodulesFile
}

# Step 4: Add all changes
Write-Host "`nStep 4: Adding all changes to git..." -ForegroundColor Yellow
git add .

# Step 5: Commit changes
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "Update AI News Collection - $timestamp"
Write-Host "`nStep 5: Committing changes: $commitMessage" -ForegroundColor Yellow
git commit -m $commitMessage

# Step 6: Push to master branch
Write-Host "`nStep 6: Pushing to master branch..." -ForegroundColor Yellow
git push origin master

Write-Host "`nDone! Changes have been pushed to GitHub." -ForegroundColor Green
Write-Host "GitHub Pages should update automatically within a few minutes." -ForegroundColor Green
Write-Host "Check the Actions tab in your GitHub repository to monitor deployment progress." -ForegroundColor Green
