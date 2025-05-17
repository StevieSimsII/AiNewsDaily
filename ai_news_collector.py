import requests
import csv
import os
import datetime
import time
import logging
import re
import feedparser
import ssl
import html
from pathlib import Path
from urllib.parse import urlparse
from bs4 import BeautifulSoup  # Added for better HTML cleaning

# Try to create unverified HTTPS context for feedparser (needed for some feeds)
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(Path(__file__).parent / "ai_news_collector.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("AI_News_Collector")

# Configuration
CSV_OUTPUT_PATH = Path(__file__).parent / "ai_news.csv"
HISTORY_FILE = Path(__file__).parent / "article_history.txt"
MAX_ARTICLES_PER_SOURCE = 5

# List of RSS feeds focused on AI and ML topics
RSS_FEEDS = [
    # Tech publications with AI content
    "https://www.technologyreview.com/feed/",          # MIT Technology Review
    "https://www.wired.com/feed/tag/artificial-intelligence/rss",  # Wired AI
    "https://www.wired.com/feed/tag/machine-learning/rss",        # Wired ML
    "https://www.theverge.com/rss/ai-artificial-intelligence/index.xml",  # The Verge AI
    "https://techcrunch.com/category/artificial-intelligence/feed/",     # TechCrunch AI
    
    # AI research sources
    "https://blog.google/technology/ai/rss/",          # Google AI Blog
    "https://openai.com/blog/rss/",                    # OpenAI Blog
    "http://news.mit.edu/rss/topic/artificial-intelligence2",  # MIT AI News
    
    # AI Industry news
    "https://venturebeat.com/category/ai/feed/",       # VentureBeat AI
    "https://www.zdnet.com/topic/artificial-intelligence/rss.xml",  # ZDNet AI
    
    # Research and Analysis Firms
    "https://www.gartner.com/en/newsroom/press-releases.xml",  # Gartner Press Releases
    "https://www.gartner.com/smarterwithgartner/feed/",        # Smarter with Gartner
    "https://www.forrester.com/blogs/feed/",                   # Forrester Blogs
    "https://www.forrester.com/press-newsroom/feed/"           # Forrester Press Room
]

# Keywords to filter articles
AI_KEYWORDS = [
    "artificial intelligence", "machine learning", "deep learning", 
    "neural network", "ai ", " ai,", " ai.", "large language model", "llm", 
    "generative ai", "gpt", "chatgpt", "transformer", "diffusion model",
    "computer vision", "natural language processing", "nlp", "reinforcement learning",
    # Analyst-specific terms
    "ai adoption", "ai strategy", "ai market", "ai trends", "ai forecast",
    "ai capabilities", "ai maturity", "ai governance", "ai ethics",
    "enterprise ai", "ai implementation", "ai analytics", "ai automation",
    "ai research", "ai report", "ai study", "ai survey", "ai analysis",
    "magic quadrant ai", "wave ai", "forrester wave", "gartner magic quadrant",
    "ai benchmark", "ai research", "ai ROI", "ai investment",
    # Additional AI keywords
    "multimodal ai", "foundation model", "fine-tuning", "prompt engineering",
    "ai agent", "ai assistant", "autonomous ai", "sentiment analysis",
    "ai regulation", "responsible ai", "ai bias", "ai explainability",
    "ai inference", "ai compute", "language model", "claude", "gemini",
    "ai startup", "ai funding", "ai acquisition", "synthetic data",
    "ai hardware", "ai chip", "ai accelerator", "neuromorphic computing"
]

# AI topic categories for better classification
AI_CATEGORIES = {
    "generative ai": ["generative ai", "text-to-image", "diffusion model", "stable diffusion", "midjourney", "dall-e"],
    "language models": ["large language model", "llm", "gpt", "chatgpt", "claude", "gemini", "palm", "transformer"],
    "computer vision": ["computer vision", "image recognition", "object detection", "facial recognition"],
    "nlp": ["natural language processing", "nlp", "sentiment analysis", "text analytics", "language understanding"],
    "ai ethics": ["ai ethics", "responsible ai", "ai bias", "ai fairness", "ai transparency", "ai explainability"],
    "ai business": ["ai strategy", "ai adoption", "ai implementation", "enterprise ai", "ai roi", "ai investment"],
    "ai research": ["ai research", "ai paper", "ai study", "neural network", "deep learning"],
    "ai regulation": ["ai regulation", "ai policy", "ai governance", "ai compliance", "ai law"],
    "ai applications": ["ai in healthcare", "ai in finance", "ai in retail", "ai in manufacturing", "ai in education"]
}

def is_ai_related(title, description):
    """Check if an article is related to AI based on its title and description."""
    text = (title + " " + description).lower()
    return any(keyword.lower() in text for keyword in AI_KEYWORDS)

def clean_html(html_text):
    """Remove HTML tags from text using BeautifulSoup for better results."""
    if not html_text:
        return ""
    try:
        # Use BeautifulSoup for more robust HTML cleaning
        soup = BeautifulSoup(html_text, "html.parser")
        return soup.get_text(separator=" ", strip=True)
    except Exception as e:
        # Fallback to regex if BeautifulSoup fails
        logger.warning(f"BeautifulSoup HTML cleaning failed, using regex fallback: {str(e)}")
        clean_text = re.sub(r'<.*?>', '', html_text)
        return clean_text.strip()

def determine_ai_category(text):
    """Determine the most specific AI category for the article."""
    text = text.lower()
    
    # Check each category
    for category, keywords in AI_CATEGORIES.items():
        if any(keyword in text for keyword in keywords):
            return category
    
    # Default to general AI if no specific category is found
    return "artificial intelligence"

def extract_research_insights(text, source):
    """Extract key insights from research firm content."""
    if not text:
        return ""
    
    # Extract sentences that contain specific research-related terms
    insights = []
    sentences = re.split(r'(?<=[.!?])\s+', text)
    
    research_terms = [
        "report", "study", "survey", "research", "analysis", "predict", 
        "forecast", "market", "growth", "trend", "adoption", "implementation",
        "magic quadrant", "wave", "leaders", "challengers", "visionaries",
        "percent", "percentage", "statistics", "data", "figure", "number"
    ]
    
    for sentence in sentences:
        if any(term in sentence.lower() for term in research_terms):
            insights.append(sentence)
    
    # If we found insights, join them; otherwise, return a subset of the original text
    if insights:
        return " ".join(insights)
    else:
        # Return the first 300 characters of the original text
        return text[:300] + ("..." if len(text) > 300 else "")

def get_domain(url):
    """Extract domain from URL."""
    parsed_url = urlparse(url)
    domain = parsed_url.netloc
    # Remove www. if present
    if domain.startswith('www.'):
        domain = domain[4:]
    return domain

def fetch_articles_from_rss(rss_url, max_articles=10):
    """Fetch articles from an RSS feed."""
    articles = []
    
    try:
        # Parse the RSS feed
        feed = feedparser.parse(rss_url)
        
        # Check if the feed was successfully parsed
        if not feed or hasattr(feed, 'bozo_exception') and feed.bozo_exception:
            logger.warning(f"Feed parsing warning for {rss_url}: {feed.bozo_exception if hasattr(feed, 'bozo_exception') else 'Unknown error'}")
        
        # Check if we have entries
        if not hasattr(feed, 'entries') or len(feed.entries) == 0:
            logger.warning(f"No entries found in feed: {rss_url}")
            return articles
        
        # Identify if this is a research firm feed
        domain = get_domain(rss_url)
        is_research_firm = any(firm in domain for firm in ["gartner", "forrester"])
        
        logger.info(f"Processing {len(feed.entries)} entries from {domain}")
        
        # Process each entry in the feed
        for entry in feed.entries[:max_articles * 2]:  # Get more articles for research firms so we can filter properly
            # Extract basic information
            title = entry.get('title', '')
            link = entry.get('link', '')
            
            # Get description (summary) from various possible fields
            description = ''
            if 'summary' in entry:
                description = clean_html(entry.summary)
            elif 'description' in entry:
                description = clean_html(entry.description)
            elif 'content' in entry and entry.content:
                # Some feeds use 'content' instead of summary/description
                content_value = entry.content[0].value if isinstance(entry.content, list) else entry.content
                description = clean_html(content_value)
            
            # Get published date
            pub_date = datetime.datetime.now().strftime("%Y-%m-%d")  # Default to today
            if 'published_parsed' in entry and entry.published_parsed:
                pub_date = time.strftime("%Y-%m-%d", entry.published_parsed)
            elif 'updated_parsed' in entry and entry.updated_parsed:
                pub_date = time.strftime("%Y-%m-%d", entry.updated_parsed)
            
            # For research firms, we want to be more selective about AI content
            if is_research_firm:
                # Use a higher threshold for research firms - must have AI keywords in title or early in description
                if not any(keyword.lower() in title.lower() for keyword in AI_KEYWORDS):
                    # If not in title, check if early in description (first 150 chars)
                    short_desc = description[:150].lower() if description else ""
                    if not any(keyword.lower() in short_desc for keyword in AI_KEYWORDS):
                        continue
            else:
                # For regular sources, use the standard AI relevance check
                if not is_ai_related(title, description):
                    continue
            
            # Add the article to our list
            source = domain
            
            articles.append({
                'title': title,
                'description': description,
                'link': link,
                'date': pub_date,
                'source': source
            })
            
            if len(articles) >= max_articles:
                break
        
        logger.info(f"Found {len(articles)} AI-related articles from {domain}")
    
    except Exception as e:
        logger.error(f"Error fetching articles from {rss_url}: {str(e)}")
    
    return articles

def get_processed_article_ids():
    """Get a list of article IDs that have already been processed."""
    if not os.path.exists(HISTORY_FILE):
        return set()
    
    with open(HISTORY_FILE, "r") as f:
        return set(line.strip() for line in f)

def save_article_id(article_id):
    """Save an article ID to the history file."""
    with open(HISTORY_FILE, "a") as f:
        f.write(f"{article_id}\n")

def collect_news():
    """Collect news articles and save them to a CSV file."""
    logger.info("Starting news collection")
    
    # Get previously processed article IDs
    processed_ids = get_processed_article_ids()
    
    # Prepare CSV file
    file_exists = os.path.exists(CSV_OUTPUT_PATH)
    
    with open(CSV_OUTPUT_PATH, mode='a', newline='', encoding='utf-8') as file:
        fieldnames = ['date', 'title', 'description', 'source', 'url', 'category', 'source_type', 'insights']
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        
        # Write header only if the file doesn't exist
        if not file_exists:
            writer.writeheader()
        
        # Track new articles added
        new_articles_count = 0
        
        # Process each RSS feed
        for feed_url in RSS_FEEDS:
            source_domain = get_domain(feed_url)
            logger.info(f"Fetching articles from: {source_domain}")
            
            try:
                # Determine specific source type
                if "gartner" in source_domain:
                    source_type = "Gartner Research"
                elif "forrester" in source_domain:
                    source_type = "Forrester Research"
                else:
                    source_type = "News Source"
                
                articles = fetch_articles_from_rss(feed_url, MAX_ARTICLES_PER_SOURCE)
                
                for article in articles:
                    # Use the article URL as a unique ID
                    article_id = article['link']
                    
                    # Skip if we've already processed this article
                    if article_id in processed_ids:
                        continue
                    
                    # Extract AI/ML category from keywords found in the article
                    text = (article['title'] + " " + article['description']).lower()
                    category = determine_ai_category(text)
                      
                    # For research content, extract insights
                    insights = ""
                    if "Research" in source_type:
                        insights = extract_research_insights(article['description'], source_domain)
                    
                    # Decode HTML entities in title and description
                    title = html.unescape(article['title'])
                    description = html.unescape(article['description'])
                    
                    # Write to CSV
                    writer.writerow({
                        'date': article['date'],
                        'title': title,
                        'description': description,
                        'source': article['source'],
                        'url': article_id,
                        'category': category,
                        'source_type': source_type,
                        'insights': insights
                    })
                    
                    # Save the article ID to avoid duplicates in future runs
                    save_article_id(article_id)
                    
                    new_articles_count += 1
                
                # Respect the server by waiting between requests
                time.sleep(2)
                
            except Exception as e:
                logger.error(f"Error processing feed {feed_url}: {str(e)}")
        
        logger.info(f"Added {new_articles_count} new articles to {CSV_OUTPUT_PATH}")

if __name__ == "__main__":
    try:
        collect_news()
    except Exception as e:
        logger.error(f"Unhandled exception in the main process: {str(e)}")
