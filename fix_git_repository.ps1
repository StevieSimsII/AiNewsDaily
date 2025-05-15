# Script to fix Git repository structure issues
# This script removes nested .git directories that cause conflicts with GitHub Pages deployment

Write-Host "Starting Git repository structure fix..." -ForegroundColor Cyan

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Working in directory: $scriptPath" -ForegroundColor Yellow

# Check for nested .git directories
$nestedGitDirs = Get-ChildItem -Path $scriptPath -Recurse -Hidden -Directory -Filter ".git" | 
    Where-Object { $_.FullName -ne (Join-Path $scriptPath ".git") }

if ($nestedGitDirs.Count -eq 0) {
    Write-Host "No nested .git directories found. Repository structure is correct." -ForegroundColor Green
} else {
    Write-Host "Found $($nestedGitDirs.Count) nested .git directories that need to be removed:" -ForegroundColor Red
    
    foreach ($gitDir in $nestedGitDirs) {
        Write-Host "  - $($gitDir.FullName)" -ForegroundColor Yellow
        
        # Remove the nested .git directory
        try {
            Remove-Item -Recurse -Force $gitDir.FullName
            Write-Host "    Removed successfully" -ForegroundColor Green
        } catch {
            Write-Host "    Failed to remove: $_" -ForegroundColor Red
        }
    }
}

# Validate GitHub Pages structure
$docsDir = Join-Path $scriptPath "docs"
if (Test-Path $docsDir) {
    Write-Host "Checking GitHub Pages structure in docs folder..." -ForegroundColor Cyan
    
    # Check for workflows in docs folder
    $docsWorkflowsDir = Join-Path $docsDir ".github\workflows"
    if (Test-Path $docsWorkflowsDir) {
        Write-Host "Found workflows in docs folder. These may cause conflicts." -ForegroundColor Yellow
        Write-Host "Removing workflows from docs folder..." -ForegroundColor Yellow
        
        try {
            Remove-Item -Recurse -Force $docsWorkflowsDir
            Write-Host "Removed workflows from docs folder successfully" -ForegroundColor Green
        } catch {
            Write-Host "Failed to remove workflows from docs folder: $_" -ForegroundColor Red
        }
    }
}

# Ensure root .github/workflows directory exists with proper files
$rootWorkflowsDir = Join-Path $scriptPath ".github\workflows"
if (-not (Test-Path $rootWorkflowsDir)) {
    Write-Host "Creating .github/workflows directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $rootWorkflowsDir | Out-Null
}

Write-Host "Git repository structure fix completed!" -ForegroundColor Cyan
Write-Host "Next step: Update your GitHub repository settings to use GitHub Actions for Pages deployment." -ForegroundColor Magenta
