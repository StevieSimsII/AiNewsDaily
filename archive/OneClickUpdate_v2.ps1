# One-step AI News Daily updater
# By: GitHub Copilot
# Date: May 15, 2025
# Version 2.0 - With improved Git handling

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - One-Step Updater v2.0" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
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
    if (Test-Path $docsGithubDir) {
        try {
            Remove-Item -Recurse -Force $docsGithubDir -ErrorAction Stop
        } catch {
            Write-Host "Warning: Could not remove existing .github directory in docs. Detailed error: $_" -ForegroundColor Yellow
        }
    }
    
    try {
        Copy-Item -Recurse $githubDir $docsGithubDir -ErrorAction Stop
        Write-Host "Copied .github directory with workflows to docs" -ForegroundColor Yellow
    } catch {
        Write-Host "Warning: Could not copy .github directory to docs. Detailed error: $_" -ForegroundColor Yellow
    }
}

# Step 3: Push to GitHub - Improved Version
Write-Host "`nStep 3: Pushing to GitHub..." -ForegroundColor Green

# Make sure we're operating from the root directory
Set-Location $scriptPath

# Create or update .gitignore to prevent .git directory conflicts
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
"@ | Set-Content -Path $gitignorePath
    Write-Host "Created .gitignore file to prevent .git directory conflicts" -ForegroundColor Yellow
}

# Update date in README files to today's date
$today = Get-Date -Format "MMMM d, yyyy"
$webAppDataReadme = Join-Path $scriptPath "web_app\data\README.md"
$docsDataReadme = Join-Path $scriptPath "docs\data\README.md"

if (Test-Path $webAppDataReadme) {
    try {
        $content = Get-Content $webAppDataReadme -Raw
        if ($content -match "## Last Updated") {
            $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
            Set-Content -Path $webAppDataReadme -Value $updatedContent -NoNewline
            Write-Host "Updated date in web_app\data\README.md" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Warning: Could not update date in web_app\data\README.md: $_" -ForegroundColor Yellow
    }
}

if (Test-Path $docsDataReadme) {
    try {
        $content = Get-Content $docsDataReadme -Raw
        if ($content -match "## Last Updated") {
            $updatedContent = $content -replace "## Last Updated\s*\r?\n\s*.*?\r?\n", "## Last Updated`r`n`r`n$today`r`n"
            Set-Content -Path $docsDataReadme -Value $updatedContent -NoNewline
            Write-Host "Updated date in docs\data\README.md" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Warning: Could not update date in docs\data\README.md: $_" -ForegroundColor Yellow
    }
}

# Check if Git is properly initialized at the root level
if (-not (Test-Path (Join-Path $scriptPath ".git"))) {
    Write-Host "Git repository not found. Initializing..." -ForegroundColor Yellow
    try {
        & git init
        & git remote add origin https://github.com/steviesimsii/AiNewsDaily.git
    } catch {
        Write-Host "Error initializing Git repository: $_" -ForegroundColor Red
        Write-Host "Please run the force_fix_git.ps1 script with administrator privileges to fix Git repository issues" -ForegroundColor Red
        exit 1
    }
}

# Stage all files
try {
    Write-Host "Staging files..." -ForegroundColor Yellow
    & git add . 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Issues occurred during staging. You may need to run force_fix_git.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error staging files: $_" -ForegroundColor Red
}

# Commit changes
try {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Committing changes..." -ForegroundColor Yellow
    $commitOutput = & git commit -m "Update AI News Daily - $date" 2>&1
    
    # Check if there was anything to commit
    if ($commitOutput -match "nothing to commit" -or $commitOutput -match "no changes added") {
        Write-Host "No changes to commit. Website is already up to date." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error committing changes: $_" -ForegroundColor Red
}

# Push to GitHub
try {
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    $pushOutput = & git push -u origin main 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Push to 'main' failed, trying 'master'..." -ForegroundColor Yellow
        & git push -u origin master
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Failed to push to both 'main' and 'master' branches." -ForegroundColor Red
            Write-Host "Please run the force_fix_git.ps1 script to repair the repository." -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Error pushing to GitHub: $_" -ForegroundColor Red
}

Write-Host "`nProcess completed!" -ForegroundColor Cyan
Write-Host "Your website should be updated at: https://steviesimsii.github.io/AiNewsDaily/" -ForegroundColor Cyan
Write-Host "Note: It may take a few minutes for GitHub Pages to update." -ForegroundColor Yellow
Write-Host "You can check deployment status at: https://github.com/StevieSimsII/AiNewsDaily/actions" -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
