# AI News Daily

A daily updated collection of AI and Machine Learning news, research, and insights.

## About

AI News Daily is a web application that automatically collects and displays the latest news in artificial intelligence and machine learning. The project consists of two main components:

1. A Python script (`ai_news_collector.py`) that scrapes news from various sources and stores it in a CSV file
2. A web application (in the `web_app` directory) that displays the collected news in a user-friendly interface

The web application is deployed to GitHub Pages through the `docs` directory, making it accessible online without requiring a backend server.

## Features

- Daily collection of AI and ML news from various free RSS feeds
- Research insights from Gartner and Forrester
- Interactive visualization of AI/ML trends
- Mobile-friendly responsive design
- Search and filtering capabilities 
- Fast, lightweight, and responsive design
- No database required - all data stored in CSV format

## Project Structure

- `ai_news_collector.py`: Python script to collect AI news from various sources
- `ai_news.csv`: CSV file containing the collected AI news
- `deploy_to_github.py`: Python script to deploy the web application to GitHub Pages
- `deploy_to_github.ps1`: PowerShell script to run the deployment script
- `check_github_pages.py`: Python script to check if GitHub Pages is correctly configured
- `web_app/`: Directory containing the source files for the web application
- `docs/`: Directory containing the files for GitHub Pages deployment

## Data Sources

Articles are collected from various sources including:
- MIT Technology Review
- AI-focused news websites and blogs
- Research journals
- Industry publications

## Deployment Process

The web application is deployed to GitHub Pages using the following process:

1. First, remove any GitHub submodules if they exist:
   ```powershell
   git submodule deinit -f -- web_app
   git rm -f web_app
   git config -f .git/config --remove-section submodule.web_app
   ```

2. Make changes to the web application in the `web_app` directory

3. Run the deployment script to copy files from `web_app` to `docs`:
   ```powershell
   python deploy_to_github.py
   ```
   
   Or use the PowerShell script:
   ```powershell
   ./deploy_to_github.ps1
   ```

4. Commit and push changes to GitHub:
   ```powershell
   git add .
   git commit -m "Update web application"
   git push
   ```

5. The web application will be available at `https://yourusername.github.io/AiNewsDaily/`

## GitHub Pages Configuration

To ensure that GitHub Pages uses `index.html` as the main page instead of `README.md`, the following files have been created:

- `.nojekyll`: Prevents GitHub Pages from using Jekyll processing
- `_config.yml`: Configures GitHub Pages to use `index.html` as the main page
- `default.html`: Redirects to `index.html`
- `404.html`: Custom 404 page that redirects to the main page

## Dependencies

- Python 3.6+ with the following packages:
  - Requests
  - Feedparser
  - Pathlib
- Frontend libraries:
  - D3.js
  - Chart.js
  - Bootstrap 5

## Usage

### Collecting News Articles

To collect new AI news articles:

```powershell
python ai_news_collector.py
```

### Testing GitHub Pages Configuration

To check if GitHub Pages is correctly configured to use index.html:

```powershell
python check_github_pages.py
```

## License

This project is licensed under the MIT License.

## Contact

For more information, please contact Stephen Sims.
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


