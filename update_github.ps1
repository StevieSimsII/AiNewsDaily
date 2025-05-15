# PowerShell script to update the AI News Daily repository

# Set the current directory to the project root
Set-Location -Path $PSScriptRoot

# Define paths
$webAppPath = Join-Path -Path $PSScriptRoot -ChildPath "web_app"

# Check if web_app has a .git directory (separate repository)
$gitDirInWebApp = Join-Path -Path $webAppPath -ChildPath ".git"
if (Test-Path -Path $gitDirInWebApp) {
    Write-Host "Removing .git directory from web_app folder..." -ForegroundColor Yellow
    Remove-Item -Path $gitDirInWebApp -Recurse -Force
}

# Navigate to the web_app directory
Set-Location -Path $webAppPath

# Initialize git repository if not already initialized
if (-not (Test-Path -Path ".git")) {
    Write-Host "Initializing git repository..." -ForegroundColor Green
    git init
}

# Add all files in web_app
Write-Host "Adding files to git..." -ForegroundColor Green
git add .

# Commit the changes
Write-Host "Committing changes..." -ForegroundColor Green
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Update web app: Removed Research and Trends views, and category tags ($date)"

# Check if remote origin exists
$remoteCheck = git remote -v
if ($remoteCheck -notmatch "origin") {
    Write-Host "Adding remote origin..." -ForegroundColor Green
    git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
}

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Green
git push -u origin main

Write-Host "`nCompleted!`n" -ForegroundColor Cyan
Write-Host "Your website should be available at: https://steviesimsii.github.io/AiNewsDaily/" -ForegroundColor Cyan
Write-Host "Make sure GitHub Pages is enabled in your repository settings." -ForegroundColor Yellow
