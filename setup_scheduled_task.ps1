$scriptPath = "C:\Users\Stephen.Sims\OneDrive - Shell\VS_Code\AI_News_Collector\ai_news_collector.py"
$taskName = "AI News Collector Daily Task"

# Create a new scheduled task action
$action = New-ScheduledTaskAction -Execute "python" -Argument $scriptPath

# Create trigger for daily execution at 8:00 AM
$trigger = New-ScheduledTaskTrigger -Daily -At 8am

# Register the scheduled task (requires admin privileges)
try {
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Runs daily to collect AI/ML news articles"
    Write-Host "Scheduled task '$taskName' created successfully!"
    Write-Host "The task will run daily at 8:00 AM."
} catch {
    Write-Host "Error: Failed to create scheduled task. You may need administrator privileges."
    Write-Host "You can run this script manually or set up the task manually in Task Scheduler."
    Write-Host "Command to run: python $scriptPath"
}
