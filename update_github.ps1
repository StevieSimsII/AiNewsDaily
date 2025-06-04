# PowerShell script to update the GitHub Pages repository with the latest web app files

# Navigate to the AI News Collector directory
cd $PSScriptRoot

# Run the deployment script to prepare the files
Write-Host "Running deployment script..."
python deploy_to_github.py

# Add all changes to git
Write-Host "Adding changes to git..."
git add docs

# Commit the changes
Write-Host "Committing changes..."
$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Update web app: Removed Research and Trends views, and category tags ($date)"

# Push to GitHub
Write-Host "Pushing to GitHub..."
git push origin main

Write-Host "Done! Changes have been pushed to GitHub."
Write-Host "The updated website should be available shortly at: https://steviesimsii.github.io/AiNewsDaily/"
