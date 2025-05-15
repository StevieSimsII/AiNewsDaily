#!/usr/bin/env python
"""
GitHub Pages Verification Script

This script checks if your GitHub Pages site is correctly configured to use index.html
instead of README.md as the main page.
"""

import requests
import re
import sys
import argparse
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger("github_pages_check")

def check_github_pages(repo_url):
    """
    Check if GitHub Pages for the repository is correctly configured
    to use index.html instead of README.md.
    
    Args:
        repo_url: The GitHub repository URL
    """
    # Extract username and repo name from the URL
    match = re.search(r'github\.com/([^/]+)/([^/]+)', repo_url)
    if not match:
        logger.error(f"Invalid GitHub repository URL: {repo_url}")
        return False
    
    username, repo_name = match.groups()
    
    # Prepare the GitHub Pages URL
    github_pages_url = f"https://{username}.github.io/{repo_name}/"
    
    logger.info(f"Checking GitHub Pages at: {github_pages_url}")
    
    try:
        # Try to access the GitHub Pages site
        response = requests.get(github_pages_url, allow_redirects=True)
        
        # Check if the request was successful
        if response.status_code == 200:
            content = response.text
            
            # Check if the page content contains elements from index.html
            if "AI News Daily" in content and '<div id="news-container"' in content:
                logger.info("✅ SUCCESS: GitHub Pages is correctly displaying your index.html file.")
                return True
            else:
                logger.warning("⚠️ WARNING: GitHub Pages response did not contain expected content from index.html.")
                
                # Check if the content contains README content
                if "# AI News Daily" in content and "This repository contains a web application" in content:
                    logger.error("❌ ERROR: GitHub Pages is displaying README.md instead of index.html.")
                    logger.error("Please make sure you have a .nojekyll file in your docs directory.")
                    logger.error("Also check your _config.yml settings to ensure it's not using README.md as the index.")
                return False
        else:
            logger.error(f"❌ ERROR: GitHub Pages site returned status code {response.status_code}.")
            logger.error("Make sure your repository is correctly published to GitHub Pages.")
            return False
    
    except requests.RequestException as e:
        logger.error(f"❌ ERROR: Could not access GitHub Pages site: {e}")
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check if GitHub Pages is correctly using index.html")
    parser.add_argument("--repo", 
                        default="https://github.com/steviesimsii/AiNewsDaily", 
                        help="GitHub repository URL (default: https://github.com/steviesimsii/AiNewsDaily)")
    
    args = parser.parse_args()
    check_github_pages(args.repo)
