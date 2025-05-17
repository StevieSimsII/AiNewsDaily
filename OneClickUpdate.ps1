# OneClickUpdate.ps1
# This script performs all necessary actions to update the AI News Daily website:
# 1. Runs the news collector to gather fresh news
# 2. Deploys the web app to the docs directory
# 3. Optionally commits and pushes changes to GitHub

param(
    [switch]$PushToGitHub = $false,
    [string]$CommitMessage = "Update AI News Daily website with fresh content"
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  AI NEWS DAILY - ONE CLICK UPDATE" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command was successful
function Check-LastExitCode {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Last command failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Function to verify CSV files are in sync
function Verify-CsvSync {
    param(
        [string[]]$CsvPaths
    )
    
    Write-Host "Checking CSV files for consistency..." -ForegroundColor Yellow
    
    $foundPaths = @()
    foreach ($path in $CsvPaths) {
        if (Test-Path $path) {
            $foundPaths += $path
        }
    }
    
    if ($foundPaths.Count -lt 1) {
        Write-Host "WARNING: No CSV files found." -ForegroundColor Red
        return
    }
    
    if ($foundPaths.Count -eq 1) {
        Write-Host "Only one CSV file found at: $($foundPaths[0])" -ForegroundColor Yellow
        return
    }
    
    # Compare file sizes
    $sizesMatch = $true
    $referenceSize = (Get-Item $foundPaths[0]).Length
    
    for ($i = 1; $i -lt $foundPaths.Count; $i++) {
        $currentSize = (Get-Item $foundPaths[$i]).Length
        if ($currentSize -ne $referenceSize) {
            $sizesMatch = $false
            Write-Host "WARNING: CSV size mismatch between $($foundPaths[0]) ($referenceSize bytes) and $($foundPaths[$i]) ($currentSize bytes)" -ForegroundColor Red
        }
    }
    
    if ($sizesMatch) {
        Write-Host "All CSV files are in sync." -ForegroundColor Green
    } else {
        Write-Host "Running CSV synchronization to ensure consistency..." -ForegroundColor Yellow
        python sync_csv_files.py
        Check-LastExitCode
    }
}

# Step 0: Force synchronize all CSV files to ensure a clean start
Write-Host "Step 0: Synchronizing CSV files across all locations..." -ForegroundColor Green
python sync_csv_files.py
Check-LastExitCode
Write-Host "CSV files synchronized successfully!" -ForegroundColor Green
Write-Host ""

# Step 1: Run the news collector
Write-Host "Step 1: Collecting fresh AI news..." -ForegroundColor Green
python ai_news_collector.py
Check-LastExitCode
Write-Host "News collection completed successfully!" -ForegroundColor Green
Write-Host ""

# Step 2: Verify all CSV files are in sync
Write-Host "Step 2: Verifying CSV file..." -ForegroundColor Green
$baseDir = Get-Location
$primaryCsv = "$baseDir\docs\data\ai_news.csv"

if (Test-Path $primaryCsv) {
    Write-Host "Primary CSV file exists at: $primaryCsv" -ForegroundColor Green
    
    # Check if web_app directory is different from docs
    if (Test-Path "$baseDir\web_app" -PathType Container) {
        $webappCsv = "$baseDir\web_app\data\ai_news.csv"
        if (Test-Path $webappCsv) {
            Write-Host "Web app CSV exists and will be updated as needed by the collector script" -ForegroundColor Green
        }
    }
} else {
    Write-Host "WARNING: Primary CSV file not found at: $primaryCsv" -ForegroundColor Red
}
Write-Host "CSV verification completed!" -ForegroundColor Green
Write-Host ""

# Step 3: Run the HTML entity fixer script if it exists
if (Test-Path "fix_html_entities.py") {
    Write-Host "Step 3: Fixing any HTML entities in the data..." -ForegroundColor Green
    python fix_html_entities.py
    Check-LastExitCode
    Write-Host "HTML entity fixing completed successfully!" -ForegroundColor Green
    Write-Host ""
}

# Step 4: Deploy the web app to docs if deploy script exists
if (Test-Path "deploy_to_github.py") {
    Write-Host "Step 4: Deploying web app to docs directory..." -ForegroundColor Green
    python deploy_to_github.py
    Check-LastExitCode
    Write-Host "Web app deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
} else {
    # Copy web app files to docs directory if needed
    if (Test-Path "web_app" -PathType Container) {
        Write-Host "Step 4: Copying web app files to docs directory..." -ForegroundColor Green
        
        # Ensure docs directory exists
        if (-not (Test-Path "docs" -PathType Container)) {
            New-Item -Path "docs" -ItemType Directory | Out-Null
        }
        
        # Copy web app files to docs, excluding data directory which is already handled
        Get-ChildItem -Path "web_app" -Exclude "data" | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination "docs\" -Recurse -Force
        }
        
        Write-Host "Web app files copied successfully!" -ForegroundColor Green
        Write-Host ""
    }
}

# Step 5: Optionally commit and push changes to GitHub
if ($PushToGitHub) {
    Write-Host "Step 5: Committing and pushing changes to GitHub..." -ForegroundColor Green
    git add .
    Check-LastExitCode
    git commit -m $CommitMessage
    Check-LastExitCode
    git push
    Check-LastExitCode
    Write-Host "Changes pushed to GitHub successfully!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "NOTICE: Changes have not been pushed to GitHub." -ForegroundColor Yellow
    Write-Host "To push changes, run this script with the -PushToGitHub switch:" -ForegroundColor Yellow
    Write-Host "  .\OneClickUpdate.ps1 -PushToGitHub" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  UPDATE PROCESS COMPLETED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
