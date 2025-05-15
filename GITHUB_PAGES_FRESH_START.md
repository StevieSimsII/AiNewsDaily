# GitHub Pages Setup - Fresh Start

This guide provides simple, step-by-step instructions to properly set up GitHub Pages for your AI News Daily project, starting completely fresh.

## Step 1: Run the Reset Script

First, run the reset script to clean up your repository structure:

```powershell
.\reset_github_pages.ps1
```

This script:
- Removes any nested .git directories
- Removes any .gitmodules file
- Ensures docs is tracked normally
- Creates a .nojekyll file in the docs folder

## Step 2: Commit and Push Changes

Commit and push the changes to GitHub:

```powershell
git add .
git commit -m "Reset GitHub Pages setup"
git push origin master
```

## Step 3: Configure GitHub Repository Settings

1. Go to your GitHub repository: https://github.com/StevieSimsII/AiNewsDaily
2. Click on **Settings** (tab at the top)
3. In the left sidebar, click on **Pages**
4. Under **Build and deployment**:
   - For **Source**, select **GitHub Actions**
   - This is critical - do NOT use "Deploy from a branch"

## Step 4: Set Proper Permissions

1. Still in Settings, click on **Actions** → **General** (in the left sidebar)
2. Scroll down to "Workflow permissions"
3. Select **Read and write permissions**
4. Check **Allow GitHub Actions to create and approve pull requests**
5. Click **Save**

## Step 5: Run the OneClickUpdate Script

Run your update script to test the deployment:

```powershell
.\OneClickUpdate.ps1
```

## Step 6: Monitor Deployment

1. Go to the **Actions** tab in your GitHub repository
2. You should see a workflow run in progress
3. Wait for it to complete (green checkmark)
4. Visit your site at: https://steviesimsii.github.io/AiNewsDaily/

## Troubleshooting

If you encounter issues:

1. **Check workflow errors** in the Actions tab
2. Make sure your **repository settings** are correctly configured
3. If all else fails, create a new repository and start fresh

## Key Files

- `github-pages.yml` - The GitHub Actions workflow file
- `reset_github_pages.ps1` - Script to clean up repository structure
- `OneClickUpdate.ps1` - Your main update script
