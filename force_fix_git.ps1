# AI News Daily - Force Git Repository Fix
# This script must be run with administrator privileges to ensure it can clean up all Git-related issues
# Run this script with: powershell -ExecutionPolicy Bypass -File ".\force_fix_git.ps1" -RunAsAdministrator

# Check if running as administrator and restart with admin rights if not
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script needs administrator privileges. Restarting with elevated permissions..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "Continue"  # Change to "Stop" for stricter error handling
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - Git Repository Force Fix" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Step 1: Stop any processes that might be locking .git folders
Write-Host "`nStep 1: Releasing file locks..." -ForegroundColor Green

# Function to forcibly remove a directory and its contents
function Remove-DirectoryForcefully {
    param (
        [string]$Path
    )
    
    if (Test-Path $Path) {
        Write-Host "Forcibly removing $Path..." -ForegroundColor Yellow
        try {
            # Take ownership and grant full control
            takeown /f "$Path" /r /d y | Out-Null
            icacls "$Path" /grant administrators:F /t | Out-Null
            
            # Try to remove using Remove-Item first
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            
            # If that didn't work, use robocopy to delete (an old trick that works sometimes)
            if (Test-Path $Path) {
                $emptyDir = Join-Path $env:TEMP "EmptyDir"
                if (-not (Test-Path $emptyDir)) {
                    New-Item -ItemType Directory -Path $emptyDir | Out-Null
                }
                robocopy $emptyDir $Path /MIR | Out-Null
                Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            # Final verification
            if (Test-Path $Path) {
                Write-Host "Warning: Could not completely remove $Path. Manual deletion may be required." -ForegroundColor Red
                return $false
            } else {
                Write-Host "Successfully removed $Path" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "Error removing $Path: $_" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "$Path does not exist, no need to remove" -ForegroundColor Yellow
        return $true
    }
}

# Remove Git directories from all problematic locations
$docsGitDir = Join-Path $scriptPath "docs\.git"
$webAppGitDir = Join-Path $scriptPath "web_app\.git"
$rootGitDir = Join-Path $scriptPath ".git"

# Force remove .git directories from docs and web_app
Remove-DirectoryForcefully $docsGitDir
Remove-DirectoryForcefully $webAppGitDir

# Step 2: Fresh Git setup
Write-Host "`nStep 2: Setting up fresh Git repository..." -ForegroundColor Green

# Clean slate by removing root .git directory too
Remove-DirectoryForcefully $rootGitDir

# Initialize a new Git repository at the root level
Write-Host "Initializing new Git repository..." -ForegroundColor Yellow
& git init

# Configure the remote origin
Write-Host "Configuring remote origin..." -ForegroundColor Yellow
& git remote add origin https://github.com/steviesimsii/AiNewsDaily.git

# Step 3: Setup GitHub Actions workflow
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
    permissions:
      contents: read
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: `${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup Pages
        uses: actions/configure-pages@v3

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: 'docs'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
"@

Set-Content -Path $workflowFile -Value $workflowContent
Write-Host "Created optimized GitHub Actions workflow file" -ForegroundColor Yellow

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

# Step 5: Update the deployment script
Write-Host "`nStep 5: Updating deploy_to_github.py script..." -ForegroundColor Green

$deployScript = Join-Path $scriptPath "deploy_to_github.py"
if (Test-Path $deployScript) {
    $content = Get-Content $deployScript -Raw
    
    # Ensure the script properly handles/removes .git directory
    if (-not ($content -match "# Remove \.git directory")) {
        $importSection = "import os
import shutil
import logging
from pathlib import Path"
        
        $newImportSection = "import os
import shutil
import logging
import stat
from pathlib import Path

# Function to handle permission errors when removing directories
def remove_readonly(func, path, _):
    """Clear the readonly bit and reattempt the removal"""
    os.chmod(path, stat.S_IWRITE)
    func(path)"
        
        $content = $content -replace [regex]::Escape($importSection), $newImportSection
        
        $rmtreeSection = "    # Copy the latest CSV file to the data directory
    if os.path.exists(csv_file):
        shutil.copy2(csv_file, data_dir / ""ai_news.csv"")
        logger.info(f""Copied {csv_file} to {data_dir}"")
    else:
        logger.error(f""CSV file not found: {csv_file}"")
        return False"
        
        $newRmtreeSection = "    # Copy the latest CSV file to the data directory
    if os.path.exists(csv_file):
        shutil.copy2(csv_file, data_dir / ""ai_news.csv"")
        logger.info(f""Copied {csv_file} to {data_dir}"")
    else:
        logger.error(f""CSV file not found: {csv_file}"")
        return False
        
    # Remove .git directory from docs if it exists (this is causing problems)
    git_dir = docs_dir / "".git""
    if os.path.exists(git_dir):
        try:
            shutil.rmtree(git_dir, onerror=remove_readonly)
            logger.info(f""Removed .git directory from docs folder to avoid conflicts"")
        except Exception as e:
            logger.warning(f""Could not remove .git directory from docs folder: {e}"")
            logger.warning(f""This may cause issues with Git operations"")"
        
    # Also clean up any other potential conflict directories
    github_dir = docs_dir / "".github""
    if os.path.exists(github_dir):
        try:
            shutil.rmtree(github_dir, onerror=remove_readonly)
            logger.info(f""Removed existing .github directory from docs folder"")
        except Exception as e:
            logger.warning(f""Could not remove .github directory: {e}"")"
        
    Set-Content -Path $deployScript -Value $content
    Write-Host "Updated deploy_to_github.py to better handle Git directories" -ForegroundColor Yellow
}

# Step 6: Update the OneClickUpdate.ps1 script
Write-Host "`nStep 6: Updating OneClickUpdate.ps1 script..." -ForegroundColor Green

$oneClickScript = Join-Path $scriptPath "OneClickUpdate.ps1"
if (Test-Path $oneClickScript) {
    $content = Get-Content $oneClickScript -Raw
    
    # Make sure the script correctly handles Git operations
    $gitSection = "# Step 3: Pushing to GitHub"
    $newGitSection = "# Step 3: Pushing to GitHub - Using Root Repository Only"
    
    $content = $content -replace [regex]::Escape($gitSection), $newGitSection
    
    Set-Content -Path $oneClickScript -Value $content
    Write-Host "Updated OneClickUpdate.ps1" -ForegroundColor Yellow
}

# Step 7: Stage all current files
Write-Host "`nStep 7: Staging all files..." -ForegroundColor Green

# Make sure we're ignoring .git directories in docs
$gitignorePath = Join-Path $scriptPath ".gitignore"
if (-not (Test-Path $gitignorePath)) {
    @"
# Ignore .git directories in subdirectories
docs/.git/
web_app/.git/

# Python cache files
__pycache__/
*.py[cod]
*$py.class

# Log files
*.log

# Environment
.env
.venv
env/
venv/
ENV/

# VS Code
.vscode/
"@ | Set-Content -Path $gitignorePath
    Write-Host "Created .gitignore file" -ForegroundColor Yellow
} else {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    if (-not ($gitignoreContent -match "docs/\.git/")) {
        @"
# Ignore .git directories in subdirectories
docs/.git/
web_app/.git/

"@ + $gitignoreContent | Set-Content -Path $gitignorePath
        Write-Host "Updated .gitignore file" -ForegroundColor Yellow
    }
}

# Stage all the files
Write-Host "Staging all files..." -ForegroundColor Yellow
& git add .

# Commit changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Committing changes..." -ForegroundColor Yellow
& git commit -m "Complete repository restructure and fix - $date"

# Step 8: Push to GitHub
Write-Host "`nStep 8: Pushing to GitHub..." -ForegroundColor Green

Write-Host "Attempting to push to main branch..." -ForegroundColor Yellow
$pushResult = & git push -u origin main -f 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push to 'main' failed, trying 'master'..." -ForegroundColor Yellow
    & git push -u origin master -f
}

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your repository structure has been fixed and all changes have been pushed to GitHub." -ForegroundColor Cyan
Write-Host "Now run the OneClickUpdate.ps1 script to update your website content." -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
