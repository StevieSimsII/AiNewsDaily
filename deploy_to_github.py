import os
import shutil
import datetime
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
    data_dir = web_app_dir / "data"
    csv_file = base_dir / "ai_news.csv"
    
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
    
    # Create a README.md for the GitHub repository
    create_readme(base_dir)    
    # Create a .nojekyll file to bypass Jekyll processing on GitHub Pages
    nojekyll_file = web_app_dir / ".nojekyll"
    with open(nojekyll_file, 'w') as f:
        pass  # Create an empty file
    logger.info(f"Created .nojekyll file")
    
    logger.info("\nDeployment preparation complete!")
    logger.info("\nTo deploy to GitHub Pages:")
    logger.info("1. Create a GitHub repository (suggested name: AiNewsDaily)")
    logger.info("2. Push the contents of the 'web_app' directory to the repository")
    logger.info("3. Go to Settings > Pages in your repository")
    logger.info("4. Select 'Deploy from branch' and choose 'main' or 'master' and root folder")
    logger.info("5. Click Save")
    logger.info("\nYour site will be available at https://steviesimsii.github.io/AiNewsDaily")
    
    
    return True

def create_readme(base_dir):
    """Create a README.md file for the GitHub repository."""
    readme_content = """# AI News Daily

A daily updated collection of AI and Machine Learning news, research, and insights.

## About

AI News Daily is an automated news aggregator that collects the latest articles, research, and insights from leading technology and research sources including Gartner and Forrester.

## Features

- Daily collection of AI and ML news from various free RSS feeds
- Research insights from Gartner and Forrester
- Interactive visualization of AI/ML trends
- Mobile-friendly responsive design
- Search and filtering capabilities

## Data Sources

Articles are collected from various sources including:
- MIT Technology Review
- Wired
- The Verge
- TechCrunch
- Google AI Blog
- OpenAI Blog
- MIT AI News
- VentureBeat
- ZDNet
- Gartner Research
- Forrester Research

## Updates

The data is updated daily at 8:00 AM.

## Contact

Maintained by: Stephen Sims (stephen.sims@shell.com)
GitHub: [steviesimsii](https://github.com/steviesimsii)

## Local Development

To run this project locally:

1. Clone the repository
2. Open `index.html` in your browser
3. For the best experience, use a local server

## License

Free for personal and commercial use.
"""
    
    readme_file = base_dir / "web_app" / "README.md"
    with open(readme_file, 'w') as f:
        f.write(readme_content)
    
    logger.info(f"Created README.md file")

if __name__ == "__main__":
    deploy_to_github_pages()
