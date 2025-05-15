# AI News Daily - One-Click Update Instructions

## Overview
The OneClickUpdate.ps1 script automates the entire process of collecting new articles and updating your GitHub Pages website. This is a major time-saver compared to running each step manually.

## How to Use

### Method 1: From PowerShell (Recommended)
1. Open PowerShell
2. Navigate to this folder: `cd "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector"`
3. Run: `powershell -ExecutionPolicy Bypass -File ".\OneClickUpdate.ps1"`

### Method 2: Create a Desktop Shortcut
1. Right-click on your desktop
2. Select New > Shortcut
3. Enter this command: `powershell -ExecutionPolicy Bypass -File "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector\OneClickUpdate.ps1"`
4. Name the shortcut "AI News Daily Updater"

### Method 3: From VS Code
1. Open this project in VS Code
2. Open the file "OneClickUpdate.ps1"
3. Right-click in the editor and select "Run in Terminal"

## What it Does
1. Collects new AI and ML articles from all your sources
2. Prepares the files for GitHub Pages in the docs folder
3. Commits and pushes the changes to your GitHub repository
4. Updates your live website at https://steviesimsii.github.io/AiNewsDaily/

## Scheduling for Daily Updates

### Option 1: Using setup_scheduled_task.ps1 (Automated)
The easiest way to schedule daily updates is to use the provided scheduler script:

1. Open PowerShell as Administrator
2. Navigate to this folder: `cd "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector"`
3. Run: `powershell -ExecutionPolicy Bypass -File ".\setup_scheduled_task.ps1"`

This will create a Windows Scheduled Task that runs the updater daily at 8:00 AM.

### Option 2: Manual Windows Task Scheduler Setup
If you prefer to set up the task manually:

1. Open Task Scheduler (search for it in the Start menu)
2. Select "Create Basic Task" from the right panel
3. Name it "AI News Daily Update" and add a description
4. Select "Daily" for the trigger
5. Set the start time to 8:00 AM (or your preferred time)
6. Choose "Start a program" for the action
7. Program/script: `powershell`
8. Add arguments: `-ExecutionPolicy Bypass -File "c:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector\OneClickUpdate.ps1"`
9. Finish the wizard

## Troubleshooting
If you encounter any issues:
- Make sure Git is installed and configured
- Check that your GitHub repository is correctly set up
- Verify that GitHub Pages is enabled in your repository settings

## Created
May 15, 2025
