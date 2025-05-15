# GitHub Pages Deployment Guide for AI News Collector

This guide provides comprehensive instructions for setting up and troubleshooting GitHub Pages deployment for your AI News Collector project.

## Configuration Options

GitHub Pages can be deployed in two ways:

1. **Deploy from a branch** - Directly uses content from a specific branch/folder
2. **GitHub Actions** - Uses workflows to build and deploy your site

## Current Setup (Master Branch)

Your project is configured to deploy from the `master` branch using the `docs` folder. This means:

- The contents of the `docs` directory in your master branch will be published
- GitHub Actions are configured to facilitate this deployment process
- Files in the `docs` folder are automatically copied to GitHub Pages when pushed

## Workflow File

Your GitHub Actions workflow file (`.github/workflows/deploy-github-pages.yml`) is configured to:

1. Trigger when changes are pushed to the master branch
2. Clean up any problematic Git files (nested `.git` directories and `.gitmodules` files)
3. Upload and deploy the contents of the `docs` directory

## Common Issues and Solutions

### 1. Submodule Errors

If you're experiencing errors related to Git submodules:

```
Error: fatal: No url found for submodule path 'docs' in .gitmodules
```

This happens when:
- The `docs` directory contains its own `.git` directory
- A `.gitmodules` file exists that references the `docs` directory

**Solution:** The workflow now includes steps to automatically remove these problematic files.

### 2. Deployment Not Updating

If your site isn't reflecting the latest changes:

1. Check that you pushed to the `master` branch
2. Verify the GitHub Actions workflow ran successfully
3. Ensure your changes were properly deployed to the `docs` folder

### 3. Workflow Failures

If the GitHub Actions workflow is failing:

1. Check the error message in the Actions tab of your GitHub repository
2. Verify that the `docs` directory exists and contains your web content
3. Make sure the workflow YAML file is valid

## Deployment Process

For simple deployment, use the `deploy_to_master.ps1` script:

```powershell
.\deploy_to_master.ps1
```

This script will:
1. Collect the latest AI news
2. Deploy the updated content to the docs folder
3. Clean up any problematic Git files
4. Commit and push your changes to GitHub

## GitHub Pages Settings

Make sure your GitHub repository settings are configured correctly:

1. Go to your repository on GitHub
2. Navigate to Settings > Pages
3. Under "Build and deployment", select:
   - Source: "Deploy from a branch"
   - Branch: "master" with folder: "/docs"

## Troubleshooting

If you continue to experience issues after following these steps, try:

1. Running the `reset_github_pages.ps1` script to clean up your repository structure
2. Checking the GitHub Actions logs for detailed error information
3. Validating your workflow file syntax

## Need More Help?

If problems persist, GitHub's documentation provides excellent resources:
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Troubleshooting GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/troubleshooting-404-errors-for-github-pages-sites)
