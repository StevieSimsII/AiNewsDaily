# One-step AI News Daily updater
# By: GitHub Copilot
# Date: May 15, 2025

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - One-Step Updater" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Collect new articles
Write-Host "Step 1: Collecting new AI and ML articles..." -ForegroundColor Green
python ai_news_collector.py

# Step 2: Deploy to docs
Write-Host "`nStep 2: Deploying to docs folder..." -ForegroundColor Green
python deploy_to_github.py

# Ensure .github directory is copied to docs for GitHub Actions
$githubDir = Join-Path $scriptPath ".github"
$docsGithubDir = Join-Path (Join-Path $scriptPath "docs") ".github"

if (Test-Path $githubDir) {
    # Remove existing .github directory in docs if it exists
    if (Test-Path $docsGithubDir) {
        Remove-Item -Recurse -Force $docsGithubDir
    }
    
    # Create the directory structure
    New-Item -ItemType Directory -Path $docsGithubDir -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $docsGithubDir "workflows") -Force | Out-Null
    
    # Copy workflow files
    Copy-Item -Path (Join-Path $githubDir "workflows\*.yml") -Destination (Join-Path $docsGithubDir "workflows") -Force
    Write-Host "Copied .github directory with workflows to docs" -ForegroundColor Yellow
}

# Step 3: Push to GitHub
Write-Host "`nStep 3: Pushing to GitHub..." -ForegroundColor Green

# Make sure there's no .git directory in docs
$docsGitDir = Join-Path $scriptPath "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Removing .git directory from docs folder..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir
}

# Check for and remove .gitmodules file if it exists
$gitmodulesFile = Join-Path $scriptPath ".gitmodules"
if (Test-Path $gitmodulesFile) {
    Write-Host "Found .gitmodules file that may cause submodule errors - removing it..." -ForegroundColor Yellow
    Remove-Item -Force $gitmodulesFile
}

# Fix Git's internal submodule references (this is safe even if docs isn't a submodule)
git submodule deinit -f -- docs 2>$null
git rm -f --cached docs 2>$null
Write-Host "Fixed potential Git submodule references" -ForegroundColor Yellow

# Get the current directory path
$rootDir = $scriptPath

# Check if the root directory has a Git repository
if (-not (Test-Path (Join-Path $rootDir ".git"))) {
    Write-Host "Initializing Git repository in the root directory..." -ForegroundColor Yellow
    Set-Location $rootDir
    & git init
    
    # Add remote origin
    & git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
} else {
    # Check if the remote is configured
    Set-Location $rootDir
    $remoteExists = & git remote -v
    if (-not ($remoteExists -match "origin")) {
        Write-Host "Adding remote origin..." -ForegroundColor Yellow
        & git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
    }
}

# Update date in README files to today's date
$today = Get-Date -Format "MMMM d, yyyy"
$webAppDataReadme = Join-Path $rootDir "web_app\data\README.md"
$docsDataReadme = Join-Path $rootDir "docs\data\README.md"
$webAppIndexHtml = Join-Path $rootDir "web_app\index.html"
$docsIndexHtml = Join-Path $rootDir "docs\index.html"

if (Test-Path $webAppDataReadme) {
    $content = Get-Content $webAppDataReadme -Raw
    $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $webAppDataReadme -Value $updatedContent -NoNewline
    Write-Host "Updated date in web_app\data\README.md" -ForegroundColor Yellow
}

if (Test-Path $docsDataReadme) {
    $content = Get-Content $docsDataReadme -Raw
    $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
    Set-Content -Path $docsDataReadme -Value $updatedContent -NoNewline
    Write-Host "Updated date in docs\data\README.md" -ForegroundColor Yellow
}

# Update date in web app HTML files
if (Test-Path $webAppIndexHtml) {
    $content = Get-Content $webAppIndexHtml -Raw
    $updatedContent = $content -replace "<p>Last Updated: <span id=""last-updated-date"">.*?</span></p>", "<p>Last Updated: <span id=""last-updated-date"">$today</span></p>"
    Set-Content -Path $webAppIndexHtml -Value $updatedContent -NoNewline
    Write-Host "Updated date in web_app\index.html" -ForegroundColor Yellow
}

# Stage the changes
Write-Host "Staging files..." -ForegroundColor Yellow
& git add .

# Commit the changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Committing changes..." -ForegroundColor Yellow
$commitResult = & git commit -m "Update AI News Daily - $date" 2>&1

# Push directly to master branch (since we confirmed it's working)
Write-Host "Pushing to GitHub master branch..." -ForegroundColor Yellow
& git push -u origin master

# Return to the original directory
Set-Location $scriptPath

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your website should be updated at: https://steviesimsii.github.io/AiNewsDaily/" -ForegroundColor Cyan
Write-Host "Note: It may take a few minutes for GitHub Pages to update." -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
