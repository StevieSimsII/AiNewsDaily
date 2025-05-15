# Cleanup script for AI_News_Collector
# Created: May 15, 2025

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "AI News Daily - Folder Cleanup" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Files to keep (essential files)
$essentialFiles = @(
    "ai_news_collector.py",      # Main collection script
    "analyze_research.py",       # Research analysis script
    "deploy_to_github.py",       # GitHub deployment script
    "OneClickUpdate.ps1",        # One-click update script 
    "ONE_CLICK_UPDATE_INSTRUCTIONS.md", # Instructions for one-click update
    "ai_news.csv",              # Data file
    "article_history.txt",      # History tracking file
    "ai_news_collector.log",    # Log file
    "README.md",                # Main README
    "setup_scheduled_task.ps1", # Schedule setup script
    "run_collector.bat"         # Original collector batch file
)

# Create a backup directory just in case
$backupDir = Join-Path $scriptPath "old_files_backup"
if (-not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory | Out-Null
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Yellow
}

# Get all files in the current directory (excluding directories and the backup folder)
$allFiles = Get-ChildItem -Path $scriptPath -File | Where-Object { $_.Name -ne "cleanup_script.ps1" }

Write-Host "Starting cleanup process..." -ForegroundColor Green

foreach ($file in $allFiles) {
    if ($essentialFiles -notcontains $file.Name) {
        # File is not in the essential list, move it to backup
        $destinationPath = Join-Path $backupDir $file.Name
        Write-Host "Moving non-essential file to backup: $($file.Name)" -ForegroundColor Yellow
        Move-Item -Path $file.FullName -Destination $destinationPath -Force
    }
    else {
        Write-Host "Keeping essential file: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Cyan
Write-Host "Essential files have been preserved, and other files moved to: $backupDir" -ForegroundColor Cyan
Write-Host "You can delete the backup directory if everything works correctly." -ForegroundColor Yellow

# Pause to keep the window open
Write-Host "`nPress Enter to exit..." -ForegroundColor Gray
Read-Host
