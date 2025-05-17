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
CSV_PATHS = [
    BASE_DIR / "ai_news.csv",
    BASE_DIR / "docs" / "data" / "ai_news.csv",
    BASE_DIR / "web_app" / "data" / "ai_news.csv"
]

def parse_date(date_str):
    """Convert date string to datetime object for sorting."""
    try:
        if "/" in date_str:  # MM/DD/YYYY
            return datetime.strptime(date_str, "%m/%d/%Y")
        else:  # YYYY-MM-DD
            return datetime.strptime(date_str, "%Y-%m-%d")
    except ValueError:
        logger.warning(f"Could not parse date: {date_str}")
        return datetime(1900, 1, 1)

def read_all_csv_files():
    """Read all articles from all CSV files, removing duplicates."""
    all_articles = []
    url_set = set()
    
    for csv_path in CSV_PATHS:
        if not os.path.exists(csv_path):
            logger.info(f"CSV file does not exist: {csv_path}")
            continue
            
        try:
            with open(csv_path, 'r', newline='', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                for row in reader:
                    # Skip duplicate URLs
                    if row['url'] in url_set:
                        continue
                    url_set.add(row['url'])
                    all_articles.append(row)
            
            logger.info(f"Read {len(all_articles)} articles from {csv_path}")
        except Exception as e:
            logger.error(f"Error reading CSV file {csv_path}: {str(e)}")
    
    return all_articles

def write_csv_file(csv_path, articles):
    """Write articles to CSV file."""
    try:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(csv_path), exist_ok=True)
        
        # Write to temp file first
        temp_path = csv_path.with_suffix('.temp.csv')
        with open(temp_path, 'w', newline='', encoding='utf-8') as file:
            if not articles:
                logger.warning(f"No articles to write to {csv_path}")
                return False
                
            fieldnames = ['date', 'title', 'description', 'source', 'url', 'category', 'source_type', 'insights']
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            writer.writeheader()
            
            for article in articles:
                writer.writerow(article)
        
        # Replace original file
        if os.path.exists(csv_path):
            os.remove(csv_path)
        os.rename(temp_path, csv_path)
        
        logger.info(f"Successfully wrote {len(articles)} articles to {csv_path}")
        return True
    except Exception as e:
        logger.error(f"Error writing to CSV file {csv_path}: {str(e)}")
        return False

def synchronize_csv_files():
    """Main function to synchronize all CSV files."""
    logger.info("Starting CSV synchronization")
    
    # Read all articles from all CSV files
    all_articles = read_all_csv_files()
    
    if not all_articles:
        logger.warning("No articles found in any CSV file")
        return
    
    # Sort articles by date (newest first)
    all_articles.sort(key=lambda x: parse_date(x['date']), reverse=True)
    
    # Write synchronized articles to all CSV files
    for csv_path in CSV_PATHS:
        write_csv_file(csv_path, all_articles)
    
    logger.info("CSV synchronization completed successfully")

if __name__ == "__main__":
    synchronize_csv_files()
