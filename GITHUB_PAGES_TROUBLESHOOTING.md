# GitHub Pages Deployment Troubleshooting Guide

If you're experiencing issues with GitHub Pages not showing your latest updates, follow this step-by-step guide to diagnose and fix the problems.

## Quick Fixes

Try these quick fixes first:

1. **Run the improved updater script**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\OneClickUpdate_v2.ps1"
   ```

2. **Check GitHub Actions status**:
   - Go to https://github.com/StevieSimsII/AiNewsDaily/actions
   - See if any workflows are running or have failed

3. **Verify GitHub Pages settings**:
   - Go to your repository Settings → Pages
   - Ensure source is set to "Deploy from a branch"
   - Branch should be "master" or "main" with /docs folder selected

## Step-by-Step Troubleshooting

If the quick fixes don't work, follow these more detailed steps:

### Step 1: Fix Git Repository Structure

The most common issue is having multiple `.git` directories causing conflicts. Run the force fix script:

```powershell
# Run as administrator
powershell -ExecutionPolicy Bypass -File ".\force_fix_git.ps1"
```

This script will:
- Clean up conflicting Git directories
- Set up a properly structured Git repository
- Configure GitHub Actions workflow
- Update README dates
- Commit and push all changes

### Step 2: Verify Repository Content

After running the fix script, verify that your repository has the correct structure:

1. Check that `.github/workflows/deploy-github-pages.yml` exists
2. Ensure the `docs` directory contains your website files
3. Make sure no nested `.git` directories exist

### Step 3: Manually Create a GitHub Workflow

If GitHub Actions still isn't showing up, you may need to manually create the workflow:

1. Go to your GitHub repository
2. Click on the "Actions" tab
3. Click "New workflow"
4. Click "set up a workflow yourself"
5. Replace the template with:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup Pages
        uses: actions/configure-pages@v3

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: 'docs'

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

6. Save the workflow (click "Start commit" and then "Commit new file")

### Step 4: Manually Enable GitHub Pages

If GitHub Pages is not enabled or configured correctly:

1. Go to repository Settings
2. Click on "Pages" in the sidebar
3. Under "Build and deployment" section:
   - Source: Select "GitHub Actions" (if workflow exists) or "Deploy from a branch"
   - If using branch deployment, select the branch (main/master) and folder (/docs)
4. Click "Save"

### Step 5: Verify Website Files

Make sure your website files in the `docs` directory are correct:

1. Check that `docs/index.html` exists
2. Verify that `docs/data/ai_news.csv` contains your data
3. Make sure all necessary CSS and JavaScript files are present

### Step 6: Wait for Deployment

GitHub Pages can take 5-10 minutes to deploy changes. After making changes:

1. Go to the Actions tab to see if a workflow is running
2. Wait for the workflow to complete
3. Check your website URL: https://steviesimsii.github.io/AiNewsDaily/

## If All Else Fails

If you've tried everything and still can't get GitHub Pages to update:

1. **Create a fresh clone**: 
   ```powershell
   cd ..
   mkdir AI_News_Collector_Fresh
   cd AI_News_Collector_Fresh
   git clone https://github.com/steviesimsii/AiNewsDaily.git .
   ```

2. **Copy your latest data**:
   ```powershell
   copy ..\AI_News_Collector\ai_news.csv .\ai_news.csv
   ```

3. **Run the collector and updater**:
   ```powershell
   python ai_news_collector.py
   python deploy_to_github.py
   ```

4. **Push changes directly**:
   ```powershell
   git add .
   git commit -m "Fresh update with latest data"
   git push
   ```

5. **Contact GitHub Support** if the problem persists.

## Monitoring Deployment Status

After pushing changes, you can monitor the deployment:

1. **GitHub Actions Tab**: Shows workflow runs and their status
2. **Repository Settings → Pages**: Shows the latest deployment status
3. **GitHub Pages URL**: Check if your site is accessible and up-to-date

Remember that GitHub Pages usually takes a few minutes to update after a successful workflow run.
