import os
import csv
import logging
import shutil
from pathlib import Path
from datetime import datetime

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("CSV_Synchronizer")

# Configuration - must match the paths in ai_news_collector.py
BASE_DIR = Path(__file__).parent
CSV_OUTPUT_PATH = BASE_DIR / "ai_news.csv"
DOCS_CSV_PATH = BASE_DIR / "docs" / "data" / "ai_news.csv"
WEBAPP_CSV_PATH = BASE_DIR / "web_app" / "data" / "ai_news.csv"

# All possible CSV paths to check and update
CSV_PATHS = [CSV_OUTPUT_PATH, DOCS_CSV_PATH, WEBAPP_CSV_PATH]

def parse_date(date_str):
    """Convert various date formats to datetime objects for sorting."""
    try:
        # Try to parse ISO format (YYYY-MM-DD)
        return datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        try:
            # Try to parse MM/DD/YYYY format
            return datetime.strptime(date_str, "%m/%d/%Y")
        except ValueError:
            try:
                # Try one more common format
                return datetime.strptime(date_str, "%d-%m-%Y")
            except ValueError:
                # If all parsing fails, return a very old date to sort at the bottom
                logger.warning(f"Could not parse date format: {date_str}")
                return datetime(1900, 1, 1)

def read_csv_file(csv_path):
    """Read a CSV file and return its rows as dictionaries."""
    articles = []
    urls = set()
    
    if not os.path.exists(csv_path):
        logger.warning(f"CSV file does not exist: {csv_path}")
        return articles, urls
    
    try:
        with open(csv_path, mode='r', newline='', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                # Prevent duplicate URLs
                if 'url' in row and row['url'] not in urls:
                    articles.append(row)
                    urls.add(row['url'])
    except Exception as e:
        logger.error(f"Error reading CSV file {csv_path}: {str(e)}")
    
    return articles, urls

def write_csv_file(csv_path, articles):
    """Write articles to a CSV file."""
    try:
        # Ensure directory exists
        os.makedirs(os.path.dirname(csv_path), exist_ok=True)
        
        # Write to a temporary file first
        temp_file = csv_path.with_suffix('.temp.csv')
        with open(temp_file, mode='w', newline='', encoding='utf-8') as file:
            if articles:
                fieldnames = ['date', 'title', 'description', 'source', 'url', 'category', 'source_type', 'insights']
                writer = csv.DictWriter(file, fieldnames=fieldnames)
                writer.writeheader()
                for article in articles:
                    writer.writerow(article)
        
        # Replace the old file with the new one
        if os.path.exists(csv_path):
            os.remove(csv_path)
        os.rename(temp_file, csv_path)
        
        logger.info(f"Successfully wrote {len(articles)} articles to {csv_path}")
        return True
    except Exception as e:
        logger.error(f"Error writing to CSV file {csv_path}: {str(e)}")
        return False

def find_best_csv():
    """Find the CSV file with the most articles and most recent data."""
    best_csv = None
    max_article_count = 0
    max_recent_date = datetime(1900, 1, 1)
    
    for csv_path in CSV_PATHS:
        if os.path.exists(csv_path):
            articles, _ = read_csv_file(csv_path)
            
            # Skip empty files
            if not articles:
                continue
            
            # Check article count
            article_count = len(articles)
            
            # Check for recency of data by looking at the newest date
            newest_date = max([parse_date(article['date']) for article in articles], default=datetime(1900, 1, 1))
            
            # Decision logic: prioritize file with most recent data, then most articles
            if newest_date > max_recent_date:
                max_recent_date = newest_date
                max_article_count = article_count
                best_csv = csv_path
            elif newest_date == max_recent_date and article_count > max_article_count:
                max_article_count = article_count
                best_csv = csv_path
    
    return best_csv, max_article_count

def merge_all_articles():
    """Merge articles from all CSV files."""
    all_articles = []
    all_urls = set()
    
    # Read all CSV files
    for csv_path in CSV_PATHS:
        if os.path.exists(csv_path):
            articles, _ = read_csv_file(csv_path)
            for article in articles:
                if article['url'] not in all_urls:
                    all_articles.append(article)
                    all_urls.add(article['url'])
    
    # Sort articles by date in descending order
    all_articles.sort(key=lambda x: parse_date(x['date']), reverse=True)
    
    return all_articles

def synchronize_csv_files():
    """Synchronize all CSV files by creating a master merged file and distributing it."""
    logger.info("Starting CSV file synchronization")
    
    # Get articles from all CSV files
    all_articles = merge_all_articles()
    
    if not all_articles:
        logger.warning("No articles found in any CSV file. Nothing to synchronize.")
        return
    
    logger.info(f"Found {len(all_articles)} unique articles across all CSV files")
    
    # Write the merged articles to all CSV paths
    for csv_path in CSV_PATHS:
        success = write_csv_file(csv_path, all_articles)
        if success:
            logger.info(f"Successfully updated {csv_path}")
        else:
            logger.error(f"Failed to update {csv_path}")
    
    logger.info("CSV synchronization completed successfully")

if __name__ == "__main__":
    synchronize_csv_files()
