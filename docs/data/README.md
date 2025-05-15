# AI News Daily - Data Directory

This directory contains the CSV data files used by the AI News Daily web application.

## File Structure

- `ai_news.csv`: The main data file containing all collected news articles, updated daily.

## Data Format

The CSV file contains the following columns:
- **Title**: The article title
- **Source**: The source website or publication
- **URL**: Link to the original article
- **Date**: Publication date
- **Description**: Brief summary or excerpt
- **Category**: Article category or topic
- **Research_Insights**: Extracted insights (for research articles)

## Updating the Data

This data is automatically updated through the following methods:

### Automated Updates

The data is updated daily at 8:00 AM via a scheduled task.

### Manual Updates

To manually update this data:

1. From the root directory, run the OneClickUpdate.ps1 script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".\OneClickUpdate.ps1"
   ```

2. This script will:
   - Collect new AI/ML articles from all configured sources
   - Process and filter the articles
   - Update this CSV file with new entries
   - Push changes to GitHub

For more detailed information, see the `ONE_CLICK_UPDATE_INSTRUCTIONS.md` file in the project root.

## Data Retention

The system maintains a history of collected articles to prevent duplicates. The full article history is stored in the `article_history.txt` file in the project root.

## Last Updated

May 15, 2025
