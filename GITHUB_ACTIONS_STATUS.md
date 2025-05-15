# GitHub Actions Status Guide

## How to Check If GitHub Actions Are Running

GitHub Actions provide a way to automate workflows directly in your GitHub repository. Here's how to check their status:

1. **Go to your GitHub repository**:
   - Navigate to https://github.com/StevieSimsII/AiNewsDaily

2. **Click on the "Actions" tab**:
   - This tab is located at the top of your repository page, next to "Pull requests" and "Projects"

3. **View workflow runs**:
   - Here you'll see a list of all workflow runs, with the most recent at the top
   - Each run will have a status icon:
     - ✅ Green check: Successfully completed
     - ❌ Red X: Failed
     - 🟡 Yellow dot: In progress

4. **Check run details**:
   - Click on any workflow run to see detailed logs
   - This will show you each step of the workflow and where any errors might have occurred

## If Your Actions Aren't Showing Up

If you don't see any GitHub Actions runs in the Actions tab:

1. **Check if your workflow files are properly pushed to GitHub**:
   - Make sure the `.github/workflows` directory exists in your repository
   - Ensure your workflow files (`.yml` files) are in this directory

2. **Verify GitHub Pages configuration**:
   - Go to Settings > Pages
   - Ensure the source is set to "Deploy from a branch"
   - Confirm the branch is set to "master" and the folder is "/docs"

3. **Try a manual push**:
   ```powershell
   cd "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector"
   git add .
   git commit -m "Update GitHub Actions configuration"
   git push -u origin master
   ```

4. **Check repository permissions**:
   - Go to Settings > Actions > General
   - Make sure workflow permissions are properly set (usually "Read and write permissions")

## Normal Update Process Timeline

When everything is working correctly, here's what happens:

1. **You run the OneClickUpdate.ps1 script**:
   - It collects new articles
   - It prepares the docs directory with the web app files
   - It commits and pushes changes to GitHub (master branch)

2. **GitHub detects the push**:
   - GitHub Actions reads your workflow file (`.github/workflows/deploy-github-pages.yml`)
   - It starts the automated deployment process

3. **GitHub Pages updates**:
   - The deployment workflow copies files from your docs directory
   - It builds and publishes the GitHub Pages site
   - Your website at https://steviesimsii.github.io/AiNewsDaily/ is updated

This process typically takes 2-5 minutes from the time you push changes until they appear on the live site.

## Troubleshooting Common Issues

### Issue: "fatal: 'docs/.git' not recognized as a git repository"

This error occurs when the script is confusing which Git repository to use.

**Solution**:
1. The OneClickUpdate.ps1 script has been updated to fix this issue
2. Make sure you're using the latest version of the script
3. The correct approach is to have a single Git repository at the root of the project

### Issue: "Cannot push to repository"

If you're having trouble pushing to the repository:

**Solution**:
1. Make sure you have proper access rights to the repository
2. Verify your Git credentials are correctly configured
3. Check that you're pushing to the master branch

### Issue: "Everything up-to-date"

This message means Git didn't detect any new changes to push.

**Solution**:
1. Make sure there are actually new articles or changes to push
2. Check that files were properly staged with `git add .`
3. Verify that a commit was made before pushing

## Manual Intervention

If the automated process isn't working, you can manually update the GitHub repository:

```powershell
# Navigate to the project directory
cd "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector"

# Ensure .github directory exists with the workflow file
mkdir -p .github\workflows

# Create the workflow file if it doesn't exist
$workflowContent = @"
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup Pages
        uses: actions/configure-pages@v3

      - name: Build and deploy
        uses: actions/deploy-pages@v2
        with:
          folder: docs
"@

Set-Content -Path ".github\workflows\deploy-github-pages.yml" -Value $workflowContent

# Stage, commit and push all changes
git add .
git commit -m "Update website content - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push -u origin master
```

After running these commands, check the Actions tab on GitHub to see if the workflow runs successfully.

1. You run `OneClickUpdate.ps1`
2. The script collects articles and updates the docs folder
3. Changes are committed and pushed to GitHub
4. GitHub Actions detects the push and starts the workflow (visible in the Actions tab)
5. The workflow deploys the content to GitHub Pages
6. Your website is updated at https://steviesimsii.github.io/AiNewsDaily/

The entire process typically takes 3-5 minutes from running the script to seeing the changes live on the website.

## Troubleshooting Common Issues

### Issue: Workflow Failed
- **Solution**: Click on the failed workflow in the Actions tab to see the error logs
- Common reasons include invalid configuration or permission issues

### Issue: Changes Not Appearing on Website
- **Solution**: 
  - Check if the workflow completed successfully
  - Verify the GitHub Pages source settings
  - Try clearing your browser cache or opening the site in an incognito window

### Issue: Can't Find Actions Tab
- **Solution**: 
  - Make sure you're logged in to GitHub
  - Check if you have sufficient permissions on the repository
