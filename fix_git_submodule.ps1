# Fix Git Submodule Issues for GitHub Pages
# This script resolves the "No url found for submodule path 'docs'" error

Write-Host "Starting Git submodule error fix script..." -ForegroundColor Cyan
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Step 1: Check if docs/.git exists and remove it
$docsGitDir = Join-Path $scriptPath "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Found .git directory in docs folder - this is causing the submodule error" -ForegroundColor Red
    Write-Host "Removing docs/.git directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir
    Write-Host "Removed docs/.git directory successfully" -ForegroundColor Green
} else {
    Write-Host "No .git directory found in docs folder - checking other issues" -ForegroundColor Yellow
}

# Step 2: Check for .gitmodules file that might be causing issues
$gitmodulesFile = Join-Path $scriptPath ".gitmodules"
if (Test-Path $gitmodulesFile) {
    Write-Host "Found .gitmodules file - checking its contents" -ForegroundColor Yellow
    $content = Get-Content $gitmodulesFile -Raw
    
    if ($content -match "submodule.*docs") {
        Write-Host "The .gitmodules file contains an entry for docs - removing the file" -ForegroundColor Red
        Remove-Item -Force $gitmodulesFile
        Write-Host "Removed .gitmodules file successfully" -ForegroundColor Green
    } else {
        Write-Host ".gitmodules file doesn't contain docs entry - backing it up and removing" -ForegroundColor Yellow
        Copy-Item $gitmodulesFile "$gitmodulesFile.bak"
        Remove-Item -Force $gitmodulesFile
        Write-Host "Backed up and removed .gitmodules file" -ForegroundColor Green
    }
}

# Step 3: Update Git's internal submodule references
Write-Host "Running git commands to fix submodule references..." -ForegroundColor Yellow
Write-Host "This might show some errors if there are no submodules - that's normal" -ForegroundColor Gray

# Try to remove docs from git's internal submodule tracking
git submodule deinit -f -- docs 2>$null
git rm -f --cached docs 2>$null

# Remove submodule entries from git config
$gitConfigFile = Join-Path $scriptPath ".git\config"
if (Test-Path $gitConfigFile) {
    $gitConfig = Get-Content $gitConfigFile -Raw
    $newConfig = $gitConfig -replace "\[submodule ""docs""\][\s\S]*?\[(?=submodule|remote)", "[" -replace "\[submodule ""docs""\][\s\S]*$", ""
    
    if ($gitConfig -ne $newConfig) {
        Set-Content -Path $gitConfigFile -Value $newConfig
        Write-Host "Removed docs submodule entry from .git/config" -ForegroundColor Green
    }
}

# Step 4: Make sure docs is properly added to the repository
Write-Host "Ensuring docs folder is properly added to Git..." -ForegroundColor Yellow
git add docs
Write-Host "Added docs folder to Git repository" -ForegroundColor Green

# Step 5: Commit the changes
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Fix docs submodule issues - $date" --allow-empty

Write-Host "`nFix completed! Your repository should now be free of submodule errors." -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Run 'git push' to update your GitHub repository" -ForegroundColor White
Write-Host "2. Go to GitHub Actions tab to see if the workflow runs successfully" -ForegroundColor White
Write-Host "3. If issues persist, check the repository settings for GitHub Pages configuration" -ForegroundColor White

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
