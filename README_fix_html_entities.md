# HTML Entity Fixer for AI News CSV

## Overview

`fix_html_entities.py` is a utility script for the AI News Collector project that automatically fixes HTML entities in the CSV files storing AI news articles data. The script decodes HTML entities (like `&amp;`, `&#39;`, etc.) in the title and description fields of the news articles, converting them to their proper readable characters.

## Purpose

News data collected from various sources often contains HTML encoded entities which can affect readability. This script ensures that all text is properly decoded for:
- Better readability in the CSV files
- Proper display in web applications
- Consistent data format across the project

## Features

- Automatically detects and fixes HTML entities in CSV files
- Updates all CSV files in the project structure:
  - Main `ai_news.csv` in project root
  - Web app CSV in `/web_app/data/`
  - Documentation site CSV in `/docs/data/`
- Detailed logging of all changes made
- Creates backup files before making changes

## Usage

Simply run the script from the command line:

```
python fix_html_entities.py
```

## How It Works

1. The script reads each CSV file containing AI news data
2. It searches for HTML entities in the title and description fields (identified by patterns like `&#`)
3. When found, it uses Python's `html.unescape()` function to decode these entities
4. The fixed data is written back to the original files
5. A log file (`fix_html_entities.log`) is created with details of all changes

## Requirements

- Python 3.x
- No external dependencies (uses only standard library modules)

## Log File

The script generates a log file (`fix_html_entities.log`) that records:
- Each field that was modified
- Before and after snippets of the modified text
- Total count of fields fixed
- Any errors encountered during processing

## Integration

This script is part of the broader AI News Collector project workflow and helps maintain data quality between collection and presentation layers.
