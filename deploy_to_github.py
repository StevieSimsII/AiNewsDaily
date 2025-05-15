import os
import shutil
import logging
from pathlib import Path

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger('deploy')

def deploy_to_github_pages():
    """
    Prepares the web app for GitHub Pages by copying the latest CSV data
    and setting up the correct file structure.
    """
    base_dir = Path(__file__).parent
    web_app_dir = base_dir / "web_app"
    docs_dir = base_dir / "docs"  # GitHub Pages uses 'docs' folder by default
    data_dir = docs_dir / "data"
    csv_file = base_dir / "ai_news.csv"
    
    # Create the docs directory if it doesn't exist
    if not os.path.exists(docs_dir):
        os.makedirs(docs_dir)
        logger.info(f"Created docs directory: {docs_dir}")
    
    # Create the data directory if it doesn't exist
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
        logger.info(f"Created data directory: {data_dir}")
    
    # Copy the latest CSV file to the data directory
    if os.path.exists(csv_file):
        shutil.copy2(csv_file, data_dir / "ai_news.csv")
        logger.info(f"Copied {csv_file} to {data_dir}")
    else:
        logger.error(f"CSV file not found: {csv_file}")
        return False
    
    # Remove .git directory from docs if it exists (this is causing problems)
    git_dir = docs_dir / ".git"
    if os.path.exists(git_dir):
        try:
            shutil.rmtree(git_dir)
            logger.info(f"Removed .git directory from docs folder to avoid conflicts")
        except PermissionError:
            logger.warning(f"Could not remove .git directory from docs folder - this may cause issues")
    # Copy all web app files to the docs directory
    for item in os.listdir(web_app_dir):
        source = web_app_dir / item
        destination = docs_dir / item
        
        # Skip .git directory and data directory (data is handled separately)
        if item in [".git", "data"]:
            continue
        
        if os.path.isdir(source):
            if os.path.exists(destination):
                try:
                    shutil.rmtree(destination)
                except PermissionError:
                    logger.warning(f"Could not remove directory {destination} - skipping")
                    continue
            shutil.copytree(source, destination)
            logger.info(f"Copied directory {source} to {destination}")
        else:
            shutil.copy2(source, destination)
            logger.info(f"Copied file {source} to {destination}")
    
    # Create a .nojekyll file to bypass Jekyll processing on GitHub Pages
    nojekyll_file = docs_dir / ".nojekyll"
    with open(nojekyll_file, 'w') as f:
        pass  # Create an empty file
    logger.info(f"Created .nojekyll file")
    
    logger.info("\nDeployment preparation complete!")
    logger.info("\nYour site files are now in the 'docs' directory ready for GitHub Pages.")
    logger.info("Make sure your GitHub repository is set up to serve from the 'docs' folder.")
    
    return True

if __name__ == "__main__":
    deploy_to_github_pages()
