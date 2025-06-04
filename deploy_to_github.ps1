# Deploy to GitHub Pages
# This script runs the deploy_to_github.py script to copy files from web_app to docs
# for GitHub Pages deployment.

Write-Host "Deploying AI News Daily to GitHub Pages..." -ForegroundColor Green

# Run the deploy_to_github.py script
python deploy_to_github.py

# Check if the deployment was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment completed successfully!" -ForegroundColor Green
    Write-Host "Files have been copied from web_app to docs directory." -ForegroundColor Green
    Write-Host "You can now commit and push changes to GitHub." -ForegroundColor Green
} else {
    Write-Host "Deployment failed. Check the deploy_to_github.log file for details." -ForegroundColor Red
}
