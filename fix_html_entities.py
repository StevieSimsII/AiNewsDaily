#!/usr/bin/env python
"""
Script to fix HTML entities in the AI news CSV file
This script will read the ai_news.csv file, decode HTML entities in the title and description fields,
and write the fixed data back to the file.
"""

import csv
import html
import os
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    filename='fix_html_entities.log'
)

logger = logging.getLogger()

def fix_html_entities(input_csv, output_csv=None):
    """
    Fix HTML entities in the CSV file
    
    Args:
        input_csv (str or Path): Path to the input CSV file
        output_csv (str or Path, optional): Path to the output CSV file. If not provided, input file will be updated.
    """
    if output_csv is None:
        output_csv = str(input_csv) + '.fixed'
    
    try:
        # Read the CSV file
        with open(input_csv, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            fieldnames = reader.fieldnames
            rows = list(reader)
        
        # Fix HTML entities in title and description fields
        fixed_count = 0
        for row in rows:
            # Fix title
            if '&#' in row['title']:
                original_title = row['title']
                row['title'] = html.unescape(row['title'])
                fixed_count += 1
                logger.info(f"Fixed title: {original_title[:30]}... -> {row['title'][:30]}...")
            
            # Fix description
            if '&#' in row['description']:
                original_desc = row['description']
                row['description'] = html.unescape(row['description'])
                fixed_count += 1
                logger.info(f"Fixed description: {original_desc[:30]}... -> {row['description'][:30]}...")
        
        # Write the fixed data to the output file
        with open(output_csv, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        
        logger.info(f"Fixed {fixed_count} HTML entities in {input_csv}")
        logger.info(f"Wrote fixed data to {output_csv}")
        
        return output_csv, fixed_count
    
    except Exception as e:
        logger.error(f"Error fixing HTML entities: {e}")
        raise

def update_all_csv_files():
    """
    Update all CSV files (main, web_app/data, and docs/data)
    """
    base_dir = Path(__file__).resolve().parent
    web_app_csv = base_dir / "web_app" / "data" / "ai_news.csv"
    docs_csv = base_dir / "docs" / "data" / "ai_news.csv"
    main_csv = base_dir / "ai_news.csv"
    
    total_count = 0
    
    # Fix main CSV file
    if os.path.exists(main_csv):
        main_fixed, main_count = fix_html_entities(main_csv)
        os.replace(main_fixed, str(main_csv))
        logger.info(f"Updated main CSV file {main_csv} with fixed HTML entities")
        total_count += main_count
    
    # Fix web_app CSV file
    if os.path.exists(web_app_csv):
        web_app_fixed, web_app_count = fix_html_entities(web_app_csv)
        os.replace(web_app_fixed, str(web_app_csv))
        logger.info(f"Updated web_app CSV file {web_app_csv} with fixed HTML entities")
        total_count += web_app_count
    
    # Fix docs CSV file
    if os.path.exists(docs_csv):
        docs_fixed, docs_count = fix_html_entities(docs_csv)
        os.replace(docs_fixed, str(docs_csv))
        logger.info(f"Updated docs CSV file {docs_csv} with fixed HTML entities")
        total_count += docs_count
    
    return total_count

if __name__ == "__main__":
    print("Fixing HTML entities in AI news CSV files...")
    total_fixed = update_all_csv_files()
    print(f"Fixed {total_fixed} HTML entities across all CSV files.")
    print("See fix_html_entities.log for details.")
