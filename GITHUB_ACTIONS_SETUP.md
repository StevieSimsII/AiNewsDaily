# GitHub Actions Setup for AI News Daily

This document explains how to set up GitHub Actions for automatically deploying the AI News Daily website.

## What is GitHub Actions?

GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline. It's integrated directly into your GitHub repository.

## Why Use GitHub Actions?

Using GitHub Actions for AI News Daily provides several benefits:
- Automatic deployment to GitHub Pages when changes are pushed
- Visual logging of deployment history and status
- No need to manually trigger deployments
- Better tracking of when updates are made

## Setup Instructions

1. **Configure GitHub Pages**:
   - Go to your GitHub repository settings
   - Navigate to Pages (under "Code and automation" section)
   - Set the source to "Deploy from a branch"
   - Select the branch (master) and directory (/docs)
   - Save the settings

2. **GitHub Actions Configuration**:
   - The repository now includes a GitHub Actions workflow file in `.github/workflows/deploy-github-pages.yml`
   - This workflow automatically deploys the website whenever changes are pushed
   - No additional configuration is needed

3. **Viewing Deployment Status**:
   - In your GitHub repository, click on the "Actions" tab
   - Here you'll see all deployment runs, including successes and failures
   - Click on any run to see detailed logs of what happened during deployment

4. **Troubleshooting**:
   - If deployments aren't showing up in the Actions tab, ensure the workflow file is properly pushed to GitHub
   - If deployments fail, check the logs for error messages
   - Verify that your repository permissions allow GitHub Actions to run

## Manual Push (If Needed)

If you need to manually push changes to GitHub (should rarely be needed with the OneClickUpdate.ps1 script):

```powershell
cd "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector\docs"
git add .
git commit -m "Update website content"
git push -u origin master
```

The GitHub Actions workflow will automatically start once the push is complete.
