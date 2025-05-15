# Git Repository Fix Script
# This script will fix any issues with the Git repository setup for the AI News Collector project

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - Git Repository Fix" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Step 1: Clean up any existing Git issues
Write-Host "`nStep 1: Cleaning up Git repository structure..." -ForegroundColor Green

# Remove .git directory from docs if it exists
$docsGitDir = Join-Path $scriptPath "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Removing .git directory from docs folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir
}

# Remove .git directory from web_app if it exists
$webAppGitDir = Join-Path $scriptPath "web_app\.git"
if (Test-Path $webAppGitDir) {
    Write-Host "Removing .git directory from web_app folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $webAppGitDir
}

# Step 2: Initialize Git at the root level if needed
Write-Host "`nStep 2: Setting up Git repository..." -ForegroundColor Green

$rootGitDir = Join-Path $scriptPath ".git"
if (-not (Test-Path $rootGitDir)) {
    Write-Host "Initializing Git repository in the root directory..." -ForegroundColor Yellow
    git init
    
    # Add remote origin
    git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
} else {
    # Check if the remote is configured correctly
    $remoteExists = git remote -v
    if (-not ($remoteExists -match "origin")) {
        Write-Host "Adding remote origin..." -ForegroundColor Yellow
        git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
    } else {
        Write-Host "Remote origin already exists, updating URL..." -ForegroundColor Yellow
        git remote set-url origin https://github.com/steviesimsii/AiNewsDaily.git
    }
}

# Step 3: Make sure GitHub Actions workflow is set up
Write-Host "`nStep 3: Setting up GitHub Actions workflow..." -ForegroundColor Green

$workflowsDir = Join-Path $scriptPath ".github\workflows"
if (-not (Test-Path $workflowsDir)) {
    New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
    Write-Host "Created .github/workflows directory" -ForegroundColor Yellow
}

$workflowFile = Join-Path $workflowsDir "deploy-github-pages.yml"
$workflowContent = @"
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup Pages
        uses: actions/configure-pages@v3

      - name: Build and deploy
        uses: actions/deploy-pages@v2
        with:
          folder: docs # The folder the action should deploy
"@

Set-Content -Path $workflowFile -Value $workflowContent
Write-Host "Updated GitHub Actions workflow file" -ForegroundColor Yellow

# Step 4: Update dates in README files
Write-Host "`nStep 4: Updating dates in README files..." -ForegroundColor Green

$today = Get-Date -Format "MMMM d, yyyy"
$webAppDataReadme = Join-Path $scriptPath "web_app\data\README.md"
$docsDataReadme = Join-Path $scriptPath "docs\data\README.md"

if (Test-Path $webAppDataReadme) {
    $content = Get-Content $webAppDataReadme -Raw
    $newContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $webAppDataReadme -Value $newContent
    Write-Host "Updated date in web_app\data\README.md" -ForegroundColor Yellow
}

if (Test-Path $docsDataReadme) {
    $content = Get-Content $docsDataReadme -Raw
    $newContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $docsDataReadme -Value $newContent
    Write-Host "Updated date in docs\data\README.md" -ForegroundColor Yellow
}

# Step 5: Commit and push all changes
Write-Host "`nStep 5: Committing and pushing changes..." -ForegroundColor Green

# Stage all changes
Write-Host "Staging all files..." -ForegroundColor Yellow
git add .

# Commit changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Fix repository structure and update AI News Daily - $date"

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
$pushResult = git push -u origin main 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push to 'main' failed, trying 'master'..." -ForegroundColor Yellow
    git push -u origin master -f
}

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your repository structure has been fixed and all changes have been pushed to GitHub." -ForegroundColor Cyan
Write-Host "Now run the OneClickUpdate.ps1 script to update your website content." -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
