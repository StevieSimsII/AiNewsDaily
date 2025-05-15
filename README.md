# 🤖 AI News Daily - Artificial Intelligence & Machine Learning News Collector

This project automatically collects the latest news articles related to AI and machine learning from various free RSS feeds, saves them to a CSV file, and presents them in an interactive web application that can be deployed to GitHub Pages.

## Features

- Daily collection of AI and ML news from various free sources via RSS feeds
- Interactive web application for browsing, searching and filtering articles
- Mobile-friendly responsive design
- Automatic filtering to ensure content is AI/ML related
- Prevents duplicate articles with historical tracking
- Stores article data in an easy-to-use CSV format
- No API keys required - uses only freely available RSS feeds
- Easy deployment to GitHub Pages

## Setup Instructions

### Prerequisites

- Python 3.6 or higher
- Required Python packages (see Installation section)

### Installation

1. Install required packages:
   ```
   pip install feedparser requests
   ```

2. Configure the script (optional):
   - Modify the `RSS_FEEDS` list in the `ai_news_collector.py` file to add or remove sources
   - Adjust `MAX_ARTICLES_PER_SOURCE` to control how many articles are collected per source
   - Update `AI_KEYWORDS` to refine how articles are filtered for relevance

### Running the Script

You can run the script manually:

```
python ai_news_collector.py
```

### Setting up Automatic Daily Execution

#### Automated Task Scheduling

The collector comes with a PowerShell script that sets up automated daily execution through the Windows Task Scheduler.

##### Using the PowerShell Script

Run the included PowerShell script as administrator:

```
powershell -ExecutionPolicy Bypass -File setup_scheduled_task.ps1
```

This script will:
1. Create a new scheduled task named "AI News Collector Daily Task"
2. Configure it to run daily at 8:00 AM
3. Execute the Python script using your default Python installation
4. Provide proper error handling if task creation fails

##### How the Scheduler Works

The PowerShell script (`setup_scheduled_task.ps1`) uses the Windows Task Scheduler API to:
1. Create a task action that runs Python with the collector script as an argument
2. Set up a daily trigger at 8:00 AM
3. Register the task in the Windows Task Scheduler

The scheduled task will run in the background each day, collecting the latest AI news and appending it to your CSV file without requiring manual intervention.

##### Requirements for Scheduled Execution

- Administrator privileges (required to register the task)
- PowerShell execution policy that allows running scripts
- Python must be in your system PATH

#### Alternative: Manual Task Creation

If you prefer to set up the task manually:

1. Open Task Scheduler
2. Create a new Basic Task
3. Set it to run Daily
4. Set the start time to 8:00 AM
5. Set the action to "Start a Program"
6. Program/script: `python`
7. Add arguments: Full path to the `ai_news_collector.py` script

## Schedule Customization

If you want to customize the schedule (for example, to collect news at a different time or frequency):

### Modifying the Schedule Time

1. Edit the `setup_scheduled_task.ps1` file and change the time in this line:
   ```powershell
   $trigger = New-ScheduledTaskTrigger -Daily -At 8am
   ```
   Change `8am` to your preferred time, such as `3pm` or `12am`.

2. Re-run the script with administrator privileges.

### Advanced Scheduling Options

For more complex schedules, you can modify the trigger in the PowerShell script:

- **Multiple times per day**:
  ```powershell
  # Create multiple triggers
  $morningTrigger = New-ScheduledTaskTrigger -Daily -At 8am
  $eveningTrigger = New-ScheduledTaskTrigger -Daily -At 5pm
  
  # Register with multiple triggers
  Register-ScheduledTask -Action $action -Trigger @($morningTrigger, $eveningTrigger) -TaskName $taskName -Description "Runs twice daily to collect AI/ML news articles"
  ```

- **Weekly schedule**:
  ```powershell
  # Run only on weekdays
  $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 8am
  ```

- **Custom intervals**:
  For collecting news at specific intervals (e.g., every 6 hours), you would need to create a more complex trigger or use multiple scheduled tasks.

### Modifying an Existing Schedule

If you've already created the task and want to modify its schedule:

1. Open Task Scheduler
2. Find the "AI News Collector Daily Task"
3. Right-click and select "Properties"
4. Go to the "Triggers" tab and edit as needed

## Output

The script generates several important files:

1. `ai_news.csv` - Contains all collected news articles with the following columns:
   - `date` - Publication date
   - `title` - Article title
   - `description` - Article description or summary
   - `source` - The source domain (e.g., forrester.com, gartner.com)
   - `url` - Full URL to the article
   - `category` - AI/ML specific category based on keywords
   - `source_type` - Type of source (News Source, Gartner Research, Forrester Research)
   - `insights` - Extracted key insights from research articles

2. `article_history.txt` - Tracks processed articles to prevent duplicates
3. `ai_news_collector.log` - Log file with execution details

## Web Application

The project includes a streamlined web application that displays the collected news in an interactive interface:

### Features

- **News Browser**: View all collected articles with filtering options
- **About Section**: Information about the application and data sources
- **Search Functionality**: Search across all articles by keywords
- **Mobile-Friendly**: Responsive design works on all devices

### Local Usage

You can view the web application locally by opening `web_app/index.html` in your browser.

### Deployment to GitHub Pages

The application is currently deployed at: https://steviesimsii.github.io/AiNewsDaily/

To update the deployed application with the latest news:

1. Run the deployment script:
   ```
   python deploy_to_github.py
   ```
   This will prepare the web app directory with the latest data.

2. Push the changes to GitHub:
   ```
   .\update_github.ps1
   ```
   This will push the changes to the GitHub repository.

## Data Storage and Article Management

### How Articles Are Stored

The AI News Collector is designed to **append** new articles to the existing CSV file rather than overwriting previous content. Here's how it works:

1. **Appending vs. Overwriting**: 
   - When the script runs, it opens the CSV file in append mode (`mode='a'`), which means new articles are added to the end of the file
   - Existing articles remain in the file from previous runs
   - The CSV file grows over time as more articles are collected

2. **Duplicate Prevention**:
   - The script maintains an `article_history.txt` file that tracks all articles it has already processed
   - Each time the script runs, it checks this history file to avoid adding duplicate articles
   - Even if the same article appears in an RSS feed on multiple days, it will only be added to the CSV once

3. **CSV Structure Preservation**:
   - The CSV header is only written if the file doesn't exist yet
   - Subsequent runs will only add data rows, preserving the structure

### Long-term Data Management

As the CSV file grows over time, you may want to consider:

- **Archive Strategy**: For very long-term use (months/years), you might want to periodically archive older data by moving it to dated backup files
- **Data Analysis**: The growing dataset provides opportunities for trend analysis over time
- **Storage Requirements**: The CSV format is storage-efficient, but plan for modest growth over time depending on the number of sources

The script does not have an automatic cleanup mechanism - this is intentional to preserve the full history of AI news coverage for reference and analysis.

## How It Works

1. The script fetches RSS feeds from major technology and AI news sources, including Gartner and Forrester
2. It filters the articles to include only AI and ML related content
3. It applies special filtering for research firm content to ensure high relevance
4. It extracts the title, description, URL, source, and publication date
5. It identifies the specific AI category based on keywords in the article
6. It saves the data to a CSV file for easy analysis and viewing
7. It keeps track of articles it has already processed to avoid duplicates

## Customization

You can customize the script by modifying these parameters:
- `RSS_FEEDS`: List of RSS feed URLs to collect articles from
- `MAX_ARTICLES_PER_SOURCE`: Maximum number of articles to collect per source
- `AI_KEYWORDS`: Keywords used to identify AI-related content and categorize articles

## Troubleshooting

If you encounter issues:

1. Check the log file for error messages
2. Ensure you have internet connectivity
3. Try running the script manually to observe any errors
4. Make sure you have the required Python packages installed

### Scheduler Troubleshooting

If your scheduled task isn't running as expected:

1. Open Task Scheduler and check the status of "AI News Collector Daily Task"
2. Verify the Last Run Result for any error codes
3. Check the History tab for task execution details
4. Ensure Python is correctly installed and in your PATH variable
5. Try running the task manually from Task Scheduler by right-clicking it and selecting "Run"
6. Check that the task has proper permissions to execute
7. Verify the task trigger settings (time, frequency, etc.)

You can also manually check the task using PowerShell:

```powershell
Get-ScheduledTask -TaskName "AI News Collector Daily Task" | Get-ScheduledTaskInfo
```

## Recent Updates

- Removed category tags from article cards for a cleaner interface
- Simplified the navigation by removing Research Insights and Trends views
- Updated the deployment process for easier GitHub Pages updates

## License

Free for personal and commercial use.
