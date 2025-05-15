# Git Submodule Error Fix Guide

## Error Message

You're seeing these specific errors in your GitHub Actions workflow:

```
build: The process '/usr/bin/git' failed with exit code 128
build: No url found for submodule path 'docs' in .gitmodules
build: The process '/usr/bin/git' failed with exit code 128
```

## What's Happening

This error occurs because Git is treating your `docs` folder as a Git submodule when it's not supposed to be. This happens when:

1. The `docs` folder has its own `.git` directory
2. Git's internal configuration thinks `docs` is a submodule
3. GitHub Actions tries to check out this "submodule" but can't find its URL

## How We Fixed It

We've made the following changes to fix this issue:

1. **Updated GitHub Actions Workflow**
   - Modified the checkout step to not attempt to check out submodules
   - Added a step to check for and remove any `.git` directory in the docs folder
   - Changed the workflow structure to properly build and deploy from the docs folder

2. **Created `fix_git_submodule.ps1` Script**
   - This script removes the `.git` directory from docs
   - Removes any `.gitmodules` file that might reference docs
   - Cleans up Git's internal submodule references

3. **Updated `OneClickUpdate.ps1`**
   - Added code to detect and fix submodule issues during the update process
   - Added commands to properly handle Git references to the docs folder

## How to Run the Fix

If you're still seeing these errors after a push, run:

```powershell
.\fix_git_submodule.ps1
```

This script will:
1. Remove any `.git` directory in the docs folder
2. Clean up Git's internal references to the docs submodule
3. Commit the changes to remove the submodule references

After running the script:
1. Push the changes to GitHub
2. Go to the GitHub Actions tab to check if the workflow runs properly

## Verify the Fix

You'll know the fix worked when:
1. The GitHub Actions workflow completes without errors
2. Your site is properly deployed to GitHub Pages
3. You can visit https://steviesimsii.github.io/AiNewsDaily/ and see your latest content

## Preventing Future Issues

To prevent this issue from happening again:

1. Never create a Git repository inside the docs folder
2. Always use the `OneClickUpdate.ps1` script to update your site
3. If you need to clone the repository fresh, use:
   ```
   git clone https://github.com/StevieSimsII/AiNewsDaily.git
   ```

4. Avoid using Git commands like `git submodule add` on the docs directory

These changes should permanently fix the Git submodule error you're experiencing.
