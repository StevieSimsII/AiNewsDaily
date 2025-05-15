# GitHub Pages Deployment Troubleshooting Guide

## ⚠️ CRITICAL ISSUE: GitHub Actions Deployment Failure

Your GitHub Pages deployment is failing because GitHub's deployment method has changed, and your repository settings need to be updated.

## Step-by-Step Resolution Process

### 1️⃣ Fix GitHub Repository Settings

First, configure your repository to use GitHub Actions for Pages deployment:

1. Go to your repository: https://github.com/StevieSimsII/AiNewsDaily
2. Click on **Settings** (tab at the top)
3. In the left sidebar, click on **Pages**
4. Under **Build and deployment**:
   - For **Source**, select **GitHub Actions** (NOT "Deploy from a branch")
   - This is the most critical setting change!

### 2️⃣ Update Repository Permissions

GitHub Actions needs proper permissions to deploy your site:

1. In your repository settings, go to **Actions** → **General** (in the left sidebar)
2. Scroll down to "Workflow permissions"
3. Select "**Read and write permissions**"
4. Check "**Allow GitHub Actions to create and approve pull requests**"
5. Click **Save**

### 3️⃣ Fix Git Repository Structure

Run the repository structure fix script to remove any nested .git directories:

```powershell
powershell -ExecutionPolicy Bypass -File ".\fix_git_repository.ps1"
```

### 4️⃣ Re-Run Failed Workflow

1. Go to the **Actions** tab in your repository
2. Find the failed workflow run
3. Click the "**Re-run all jobs**" button in the top-right corner
4. Wait for completion (usually takes 2-3 minutes)

## Verification Process

After completing these steps:

1. Go to your repository's **Actions** tab
2. You should see a new workflow run in progress
3. Wait for it to complete successfully (green checkmark ✅)
4. Visit your site at https://steviesimsii.github.io/AiNewsDaily/
5. Verify the site has been updated with the latest content

## Advanced Troubleshooting

If you still encounter issues after following these steps:

### Error: "Resource not accessible by integration"

This error occurs when:
- GitHub Pages doesn't have proper access to deploy from Actions
- Solution: Make sure Workflow permissions are set to "Read and write" in repository settings

### Error: "The process '/usr/bin/git' failed with exit code 128"

This error occurs when:
- There are Git repository conflicts
- Solution: Remove nested .git directories and force clean your local repository:
  ```powershell
  # Remove nested .git directories
  Get-ChildItem -Path . -Recurse -Hidden -Directory -Filter ".git" | 
  Where-Object { $_.FullName -ne (Join-Path (Get-Location) ".git") } | 
  Remove-Item -Recurse -Force
  
  # Force clean your repository
  git clean -fd
  ```

### Error: Workflow fails with no clear error message

When this happens:
1. Check if your workflow file is valid
2. Make sure your docs directory has the correct structure
3. Try with a simple workflow file:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ master ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
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

## After Fixing the Issue

Once your GitHub Pages deployment is working:

1. Run your `OneClickUpdate.ps1` script
2. It will collect new articles and automatically deploy to GitHub Pages
3. The process should complete without errors
4. Your site will be updated with the latest AI news

Remember: GitHub now prefers using GitHub Actions for Pages deployment rather than the older "Deploy from a branch" method. Your workflow is set up for the new method, and your repository settings need to match.

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
3. Under "Build and deployment" section:   - Source: Select "GitHub Actions" (if workflow exists) or "Deploy from a branch"
   - If using branch deployment, select the branch (master) and folder (/docs)
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
