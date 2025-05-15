# Remove unnecessary files
Write-Host "Cleaning up AI_News_Collector directory..." -ForegroundColor Cyan

# Files to remove (non-essential files)
$filesToRemove = @(
    "cleanup_repo.ps1",
    "DEPLOYMENT_INSTRUCTIONS.md",
    "GITHUB_INSTRUCTIONS.md", 
    "github_setup_guide.md",
    "one_click_update.bat",
    "one_step_update.bat", 
    "push_to_github.ps1",
    "push_to_github_full.ps1", 
    "push_web_app.bat",
    "setup_github_repo.bat",
    "update_all.bat",
    "update_all.ps1", 
    "update_github.ps1",
    "update_summary.md",
    "PROJECT_SUMMARY.md"
)

foreach ($file in $filesToRemove) {
    $filePath = Join-Path $PSScriptRoot $file
    if (Test-Path $filePath) {
        Write-Host "Removing: $file" -ForegroundColor Yellow
        Remove-Item -Path $filePath -Force
    }
}

Write-Host "Cleanup complete!" -ForegroundColor Green
