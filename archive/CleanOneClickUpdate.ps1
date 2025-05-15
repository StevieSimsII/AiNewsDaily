# Clean AI News Daily One-Click Updater
# This script handles the entire process of updating the AI News Daily site
# Created: May 15, 2025

$ErrorActionPreference = "Stop"
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - Clean One-Step Updater" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean up any Git confusion
Write-Host "Cleaning up Git repository structure..." -ForegroundColor Yellow
$docsGitDir = Join-Path $scriptPath "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Removing .git directory from docs folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir -ErrorAction SilentlyContinue
}

$webAppGitDir = Join-Path $scriptPath "web_app\.git"
if (Test-Path $webAppGitDir) {
    Write-Host "Removing .git directory from web_app folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $webAppGitDir -ErrorAction SilentlyContinue
}

# Step D: Collect new articles
Write-Host "`nStep 1: Collecting new AI and ML articles..." -ForegroundColor Green
python ai_news_collector.py

# Step 2: Copy files to docs directory manually without using deploy_to_github.py
Write-Host "`nStep 2: Deploying to docs folder..." -ForegroundColor Green

# Ensure docs directory exists
$docsDir = Join-Path $scriptPath "docs"
if (-not (Test-Path $docsDir)) {
    New-Item -ItemType Directory -Path $docsDir | Out-Null
}

# Ensure docs/data directory exists
$docsDataDir = Join-Path $docsDir "data"
if (-not (Test-Path $docsDataDir)) {
    New-Item -ItemType Directory -Path $docsDataDir | Out-Null
}

# Copy CSV file to docs/data
$csvFile = Join-Path $scriptPath "ai_news.csv"
if (Test-Path $csvFile) {
    Copy-Item -Path $csvFile -Destination $docsDataDir -Force
    Write-Host "Copied ai_news.csv to docs/data directory" -ForegroundColor Yellow
}

# Copy web_app files to docs (excluding .git directory)
$webAppDir = Join-Path $scriptPath "web_app"
Get-ChildItem -Path $webAppDir | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
    if ($_.PSIsContainer) {
        # It's a directory
        if ($_.Name -ne "data") {  # Skip data directory as we handle it separately
            $targetDir = Join-Path $docsDir $_.Name
            if (Test-Path $targetDir) {
                Remove-Item -Recurse -Force $targetDir -ErrorAction SilentlyContinue
            }
            Copy-Item -Path $_.FullName -Destination $docsDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Copied directory $($_.Name) to docs" -ForegroundColor Yellow
        }
    } else {
        # It's a file
        Copy-Item -Path $_.FullName -Destination $docsDir -Force
        Write-Host "Copied file $($_.Name) to docs" -ForegroundColor Yellow
    }
}

# Create .nojekyll file to bypass Jekyll processing
$noJekyllFile = Join-Path $docsDir ".nojekyll"
if (-not (Test-Path $noJekyllFile)) {
    New-Item -Path $noJekyllFile -ItemType File -Force | Out-Null
    Write-Host "Created .nojekyll file in docs directory" -ForegroundColor Yellow
}

# Copy web_app/data/README.md to docs/data/README.md if it exists
$webAppDataReadme = Join-Path $webAppDir "data\README.md"
$docsDataReadme = Join-Path $docsDataDir "README.md"
if (Test-Path $webAppDataReadme) {
    Copy-Item -Path $webAppDataReadme -Destination $docsDataReadme -Force
    Write-Host "Copied data/README.md to docs/data directory" -ForegroundColor Yellow
}

# Update date in README files to today's date
$today = Get-Date -Format "MMMM d, yyyy"
if (Test-Path $webAppDataReadme) {
    $content = Get-Content $webAppDataReadme -Raw
    $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $webAppDataReadme -Value $updatedContent
    Write-Host "Updated date in web_app\data\README.md" -ForegroundColor Yellow
}

if (Test-Path $docsDataReadme) {
    $content = Get-Content $docsDataReadme -Raw
    $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $docsDataReadme -Value $updatedContent
    Write-Host "Updated date in docs\data\README.md" -ForegroundColor Yellow
}

# Ensure GitHub Actions workflow exists
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

# Step 3: Handle Git operations cleanly
Write-Host "`nStep 3: Pushing to GitHub..." -ForegroundColor Green

# Make sure we're in the root directory and initialize Git if needed
Set-Location $scriptPath
if (-not (Test-Path (Join-Path $scriptPath ".git"))) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    
    # Add remote origin
    git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
} else {
    # Ensure remote is correctly set
    $remoteExists = git remote -v
    if (-not ($remoteExists -match "origin")) {
        git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
    } else {
        git remote set-url origin https://github.com/steviesimsii/AiNewsDaily.git
    }
}

# Stage all changes
Write-Host "Staging files..." -ForegroundColor Yellow
git add .

# Commit changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "Update AI News Daily - $date"

# Push changes (try both main and master)
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
$mainPushResult = git push -u origin main 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push to 'main' failed, trying 'master'..." -ForegroundColor Yellow
    git push -u origin master
}

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your website should be updated at: https://steviesimsii.github.io/AiNewsDaily/" -ForegroundColor Cyan
Write-Host "Note: It may take a few minutes for GitHub Pages to update." -ForegroundColor Yellow
Write-Host "Check GitHub Actions status at: https://github.com/StevieSimsII/AiNewsDaily/actions" -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
