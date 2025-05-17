import os
import sys
from pathlib import Path

def check_web_app_files():
    """Check which CSV files exist and which might be used by the web app."""
    base_dir = Path(__file__).parent
    
    # Define all possible CSV paths
    csv_paths = [
        base_dir / "ai_news.csv",
        base_dir / "docs" / "data" / "ai_news.csv",
        base_dir / "web_app" / "data" / "ai_news.csv"
    ]
    
    print("Checking for CSV files that might be used by your web app...")
    
    # Check each path
    for path in csv_paths:
        if path.exists():
            size = path.stat().st_size
            article_count = count_articles(path)
            print(f"✓ FOUND: {path} (Size: {size/1024:.1f} KB, Articles: {article_count})")
        else:
            print(f"✗ MISSING: {path}")
    
    # Check for HTML or JS files that might reference the CSV
    print("\nChecking for web app files that might reference the CSV...")
    
    web_file_patterns = [
        "**/*.html",
        "**/*.js",
        "**/*.php"
    ]
    
    csv_references = []
    
    for pattern in web_file_patterns:
        for file_path in base_dir.glob(pattern):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if "ai_news.csv" in content:
                        csv_references.append((file_path, find_csv_path_in_file(content)))
            except:
                pass
    
    if csv_references:
        print("The following files reference ai_news.csv:")
        for file_path, csv_path in csv_references:
            print(f"  - {file_path} references: {csv_path}")
    else:
        print("No files found that explicitly reference ai_news.csv")
    
    print("\nBased on the findings, your web app is most likely using:")
    
    # Determine most likely path based on file existence and references
    likely_path = determine_likely_path(csv_paths, csv_references)
    print(f"  → {likely_path}")
    
    print("\nRecommendation:")
    print(f"Update your ai_news_collector.py script to ensure it writes to {likely_path}")

def count_articles(csv_path):
    """Count the number of articles in a CSV file (excluding header)"""
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            return sum(1 for _ in f) - 1  # -1 for header
    except:
        return 0

def find_csv_path_in_file(content):
    """Find the most likely CSV path referenced in the file content"""
    paths = []
    if "web_app/data/ai_news.csv" in content:
        paths.append("web_app/data/ai_news.csv")
    if "docs/data/ai_news.csv" in content:
        paths.append("docs/data/ai_news.csv")
    if "/ai_news.csv" in content:
        paths.append("/ai_news.csv")
    return paths if paths else "unclear reference"

def determine_likely_path(csv_paths, csv_references):
    """Determine the most likely path used by the web app"""
    # First priority: files with references
    for _, paths in csv_references:
        if isinstance(paths, list):
            for path in paths:
                if "web_app" in path:
                    return csv_paths[2]
                elif "docs" in path:
                    return csv_paths[1]
    
    # Second priority: existing files with most content
    existing_paths = [p for p in csv_paths if p.exists()]
    if existing_paths:
        return max(existing_paths, key=lambda p: p.stat().st_size)
    
    # Default
    return csv_paths[0]

if __name__ == "__main__":
    check_web_app_files()
