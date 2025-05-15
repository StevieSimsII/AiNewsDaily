# PowerShell script to clean up unnecessary files

# Set the current directory to the project root
Set-Location -Path $PSScriptRoot

# Files to remove (these are no longer needed after simplifying the application)
$filesToRemove = @(
    "analyze_research.py",
    "github_setup_guide.md",
    "push_to_github.ps1",
    "push_web_app.bat",
    "setup_github_repo.bat",
    "update_summary.md"
)

# Remove each file
foreach ($file in $filesToRemove) {
    $filePath = Join-Path -Path $PSScriptRoot -ChildPath $file
    if (Test-Path -Path $filePath) {
        Write-Host "Removing file: $file" -ForegroundColor Yellow
        Remove-Item -Path $filePath -Force
    }
    else {
        Write-Host "File not found: $file" -ForegroundColor Gray
    }
}

# Rename the deployment instructions file to be more clear
$oldPath = Join-Path -Path $PSScriptRoot -ChildPath "DEPLOYMENT_INSTRUCTIONS.md"
$newPath = Join-Path -Path $PSScriptRoot -ChildPath "GITHUB_INSTRUCTIONS.md"
if (Test-Path -Path $oldPath) {
    Write-Host "Renaming DEPLOYMENT_INSTRUCTIONS.md to GITHUB_INSTRUCTIONS.md" -ForegroundColor Yellow
    Rename-Item -Path $oldPath -NewName "GITHUB_INSTRUCTIONS.md" -Force
}

Write-Host "Cleanup completed!" -ForegroundColor Green
Write-Host "The repository now contains only the essential files for the AI News Daily application." -ForegroundColor Cyan
