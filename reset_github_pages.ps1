# Reset and Fix GitHub Pages Repository Structure
# This script cleans up the repository structure for GitHub Pages deployment

Write-Host "Starting GitHub Pages repository fix..." -ForegroundColor Cyan

# Step 1: Check if docs/.git exists and remove it
$docsGitDir = Join-Path $PSScriptRoot "docs\.git"
if (Test-Path $docsGitDir) {
    Write-Host "Found .git directory in docs folder - removing it" -ForegroundColor Yellow
    Remove-Item -Recurse -Force $docsGitDir
    Write-Host "Removed docs/.git directory successfully" -ForegroundColor Green
} else {
    Write-Host "No .git directory found in docs folder - good!" -ForegroundColor Green
}

# Step 2: Check for .gitmodules file and remove it if it exists
$gitmodulesFile = Join-Path $PSScriptRoot ".gitmodules"
if (Test-Path $gitmodulesFile) {
    Write-Host "Found .gitmodules file - removing it" -ForegroundColor Yellow
    Remove-Item -Force $gitmodulesFile
    Write-Host "Removed .gitmodules file successfully" -ForegroundColor Green
} else {
    Write-Host "No .gitmodules file found - good!" -ForegroundColor Green
}

# Step 3: Make sure docs directory is tracked normally, not as a submodule
Write-Host "Ensuring docs folder is tracked normally..." -ForegroundColor Yellow
git rm -rf --cached docs 2>$null
git add docs
Write-Host "Docs folder is now being tracked normally" -ForegroundColor Green

# Step 4: Create a .nojekyll file in docs to prevent Jekyll processing
$nojekyllFile = Join-Path $PSScriptRoot "docs\.nojekyll"
if (-not (Test-Path $nojekyllFile)) {
    Write-Host "Creating .nojekyll file in docs folder..." -ForegroundColor Yellow
    New-Item -ItemType File -Path $nojekyllFile -Force | Out-Null
    Write-Host "Created .nojekyll file successfully" -ForegroundColor Green
} else {
    Write-Host ".nojekyll file already exists in docs folder - good!" -ForegroundColor Green
}

# Step 5: Make sure the root .github/workflows directory exists with our workflow file
$workflowsDir = Join-Path $PSScriptRoot ".github\workflows"
$workflowFile = Join-Path $workflowsDir "github-pages.yml"

if (-not (Test-Path $workflowsDir)) {
    Write-Host "Creating .github/workflows directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
}

Write-Host "Repository structure has been fixed!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Magenta
Write-Host "1. Commit and push these changes" -ForegroundColor White
Write-Host "2. Go to your repository's Settings → Pages" -ForegroundColor White
Write-Host "3. Set the Source to 'GitHub Actions'" -ForegroundColor White
Write-Host "4. Check the Actions tab for the workflow status" -ForegroundColor White
Write-Host ""
