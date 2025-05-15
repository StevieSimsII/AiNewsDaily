#!/usr/bin/env python
"""
Deploy to GitHub Pages Script
This script copies the contents of the web_app directory to the docs directory
for deployment to GitHub Pages. It handles special files and ensures proper
configuration for GitHub Pages to use index.html instead of README.md.
"""

import os
import shutil
import logging
from pathlib import Path
import sys
import time

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("deploy_to_github.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger("deploy_to_github")

def create_nojekyll_file(docs_dir):
    """Create a .nojekyll file to prevent GitHub Pages from using Jekyll processing."""
    nojekyll_path = docs_dir / ".nojekyll"
    with open(nojekyll_path, "w") as f:
        f.write("")
    logger.info(f"Created .nojekyll file at {nojekyll_path}")

def create_config_yml(docs_dir):
    """Create a _config.yml file to configure GitHub Pages."""
    config_yml_path = docs_dir / "_config.yml"
    
    config_content = """# GitHub Pages configuration
name: AI News Daily
title: AI News Daily | Latest AI News and Research
description: Daily updates on AI and Machine Learning news, research, and insights.

# Force index.html to be the default page
theme: jekyll-theme-minimal
baseurl: ""
url: "https://steviesimsii.github.io/AiNewsDaily/"

# Explicitly tell GitHub to use index.html
index_page: index.html
source: ./
markdown: kramdown
highlighter: rouge

# Settings for direct serving
exclude: ["README.txt", "README.md", "README", ".git"]
include: ["index.html", ".nojekyll"]

# Disable GitHub Pages from generating a page from README.md
readme_index:
  enabled: false
  remove_originals: false
"""
    
    with open(config_yml_path, "w") as f:
        f.write(config_content)
    
    logger.info(f"Created/updated _config.yml at {config_yml_path}")

def safe_remove_dir(path):
    """Safely remove a directory with retries for Windows permission issues."""
    max_retries = 3
    retry_delay = 1
    
    for attempt in range(max_retries):
        try:
            if os.path.exists(path):
                shutil.rmtree(path)
            return True
        except PermissionError as e:
            logger.warning(f"Permission error removing {path}: {e}. Retrying in {retry_delay} seconds...")
            time.sleep(retry_delay)
            retry_delay *= 2
    
    logger.error(f"Failed to remove directory {path} after {max_retries} attempts")
    return False

def copy_web_app_to_docs():
    """Copy all files from web_app directory to docs directory."""
    # Get the base directory of the script
    base_dir = Path(__file__).resolve().parent
    web_app_dir = base_dir / "web_app"
    docs_dir = base_dir / "docs"
    
    # Create the docs directory if it doesn't exist
    os.makedirs(docs_dir, exist_ok=True)
    
    # Create the data directory in docs
    data_dir = docs_dir / "data"
    os.makedirs(data_dir, exist_ok=True)
    
    # Copy the main CSV file if it exists in the project root
    main_csv = base_dir / "ai_news.csv"
    if os.path.exists(main_csv):
        shutil.copy2(main_csv, data_dir / "ai_news.csv")
        logger.info(f"Copied {main_csv} to {data_dir / 'ai_news.csv'}")
    
    # Copy all files from web_app to docs, but individually
    if os.path.exists(web_app_dir) and os.path.isdir(web_app_dir):
        for item in os.listdir(web_app_dir):
            # Skip .git directory and data directory (data is handled separately)
            # Also skip any README.md files that might conflict with GitHub Pages
            if item in [".git", "README.md", "README.markdown", "readme.md"]:
                logger.info(f"Skipping {item} to avoid conflicts with GitHub Pages")
                continue
                
            source = web_app_dir / item
            destination = docs_dir / item
            
            try:
                if os.path.isdir(source):
                    # Handle directory copy with special handling for data directory
                    if item == "data":
                        # Copy files from web_app/data individually instead of the whole directory
                        for data_file in os.listdir(source):
                            data_source = source / data_file
                            data_dest = data_dir / data_file
                            if os.path.isfile(data_source):
                                shutil.copy2(data_source, data_dest)
                                logger.info(f"Copied data file {data_source} to {data_dest}")
                    else:
                        # For other directories, use the safe removal function
                        if os.path.exists(destination):
                            safe_remove_dir(destination)
                        shutil.copytree(source, destination)
                        logger.info(f"Copied directory {source} to {destination}")
                else:
                    # Direct file copy
                    shutil.copy2(source, destination)
                    logger.info(f"Copied file {source} to {destination}")
            except Exception as e:
                logger.error(f"Error copying {source} to {destination}: {e}")
    else:
        logger.warning(f"Web app directory {web_app_dir} does not exist or is not a directory")
    
    # Create necessary GitHub Pages configuration files
    create_nojekyll_file(docs_dir)
    create_config_yml(docs_dir)
    
    # Create a minimal README.txt file to avoid conflicts with GitHub Pages
    with open(docs_dir / "README.txt", "w") as f:
        f.write("This directory contains files for GitHub Pages deployment. Please see the index.html file for the actual content.")
    
    logger.info("Deployment to GitHub Pages completed successfully")

if __name__ == "__main__":
    logger.info("Starting deployment to GitHub Pages")
    copy_web_app_to_docs()