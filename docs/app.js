// Global variables
let allArticles = [];
let displayedArticles = [];
let currentView = 'all-news';
let currentFilter = 'all';
let articlesPerPage = 9;
let currentPage = 1;

// DOM elements
const newsContainer = document.getElementById('news-container');
const loadMoreBtn = document.getElementById('load-more-btn');
const allNewsLink = document.getElementById('all-news-link');
const aboutLink = document.getElementById('about-link');
const searchInput = document.getElementById('search-input');
const lastUpdatedSpan = document.getElementById('last-updated-date');
const filterButtons = document.querySelectorAll('.filter-btn');

// View elements
const allNewsView = document.getElementById('all-news-view');
const aboutView = document.getElementById('about-view');

// Initialize the application
document.addEventListener('DOMContentLoaded', () => {
    // Load the CSV data
    loadData();
    
    // Set up event listeners
    setupEventListeners();
});

// Function to load CSV data
async function loadData() {
    try {
        // Fetch the CSV file
        const response = await fetch('data/ai_news.csv');
        const csvText = await response.text();
        
        // Parse CSV data
        allArticles = parseCSV(csvText);
        
        // Sort articles by date (newest first)
        allArticles.sort((a, b) => new Date(b.date) - new Date(a.date));
        
        // Update last updated date
        if (allArticles.length > 0) {
            const latestDate = new Date(allArticles[0].date);
            lastUpdatedSpan.textContent = latestDate.toLocaleDateString('en-US', { 
                year: 'numeric', 
                month: 'short', 
                day: 'numeric' 
            });
        }
        
        // Initialize the articles display
        filterAndDisplayArticles();
        
    } catch (error) {
        console.error('Error loading data:', error);
        newsContainer.innerHTML = `
            <div class="col-12 text-center">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i> 
                    Error loading articles: ${error.message}
                </div>
            </div>
        `;
    }
}

// Function to parse CSV data
function parseCSV(csvText) {
    const lines = csvText.split('\n');
    const headers = lines[0].split(',');
    
    return lines.slice(1).filter(line => line.trim()).map(line => {
        // Handle commas inside quoted fields
        const values = [];
        let inQuotes = false;
        let currentValue = '';
        
        for (let i = 0; i < line.length; i++) {
            const char = line[i];
            
            if (char === '"' && (i === 0 || line[i-1] !== '\\')) {
                inQuotes = !inQuotes;
            } else if (char === ',' && !inQuotes) {
                values.push(currentValue);
                currentValue = '';
            } else {
                currentValue += char;
            }
        }
        
        values.push(currentValue); // Push the last value
        
        // Create an object from headers and values
        const article = {};
        headers.forEach((header, index) => {
            article[header.trim()] = values[index] ? values[index].replace(/^"|"$/g, '').trim() : '';
        });
        
        return article;
    });
}

// Setup event listeners
function setupEventListeners() {
    // Navigation links
    allNewsLink.addEventListener('click', (e) => {
        e.preventDefault();
        switchView('all-news');
    });
    
    aboutLink.addEventListener('click', (e) => {
        e.preventDefault();
        switchView('about');
    });
    
    // Load more button
    loadMoreBtn.addEventListener('click', () => {
        currentPage++;
        displayMoreArticles();
    });
    
    // Filter buttons
    filterButtons.forEach(button => {
        button.addEventListener('click', () => {
            filterButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');
            currentFilter = button.dataset.filter;
            currentPage = 1;
            filterAndDisplayArticles();
        });
    });
    
    // Search input
    searchInput.addEventListener('input', debounce(() => {
        currentPage = 1;
        filterAndDisplayArticles();
    }, 300));
}

// Switch between views
function switchView(view) {
    currentView = view;
    
    // Hide all views
    allNewsView.style.display = 'none';
    aboutView.style.display = 'none';
    
    // Remove active class from all nav links
    allNewsLink.classList.remove('active');
    aboutLink.classList.remove('active');
    
    // Show selected view and activate nav link
    switch (view) {
        case 'all-news':
            allNewsView.style.display = 'block';
            allNewsLink.classList.add('active');
            break;
        case 'about':
            aboutView.style.display = 'block';
            aboutLink.classList.add('active');
            break;
    }
}

// Filter and display articles
function filterAndDisplayArticles() {
    const searchTerm = searchInput.value.toLowerCase();
    
    // Apply filters
    displayedArticles = allArticles.filter(article => {
        // Search filter
        const matchesSearch = searchTerm === '' || 
            article.title.toLowerCase().includes(searchTerm) || 
            article.description.toLowerCase().includes(searchTerm);
        
        // Category filter
        let matchesFilter = true;
        if (currentFilter === 'ai') {
            matchesFilter = article.category.toLowerCase().includes('ai') || 
                            article.category.toLowerCase().includes('artificial intelligence');
        } else if (currentFilter === 'machine-learning') {
            matchesFilter = article.category.toLowerCase().includes('machine learning') || 
                            article.category.toLowerCase().includes('ml');
        } else if (currentFilter === 'gartner') {
            matchesFilter = article.source_type && article.source_type.includes('Gartner');
        } else if (currentFilter === 'forrester') {
            matchesFilter = article.source_type && article.source_type.includes('Forrester');
        }
        
        return matchesSearch && matchesFilter;
    });
    
    // Clear container
    newsContainer.innerHTML = '';
    
    if (displayedArticles.length === 0) {
        newsContainer.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="bi bi-search" style="font-size: 3rem; color: var(--primary-color);"></i>
                <p class="mt-3">No articles found matching your criteria</p>
            </div>
        `;
        loadMoreBtn.style.display = 'none';
        return;
    }
    
    // Display first page of articles
    displayArticles(1);
}

// Display articles for a given page
function displayArticles(page) {
    const startIndex = (page - 1) * articlesPerPage;
    const endIndex = Math.min(startIndex + articlesPerPage, displayedArticles.length);
    const articlesToDisplay = displayedArticles.slice(startIndex, endIndex);
    
    // Create HTML for articles
    const articlesHTML = articlesToDisplay.map(article => createArticleCard(article)).join('');
    
    if (page === 1) {
        newsContainer.innerHTML = articlesHTML;
    } else {
        newsContainer.insertAdjacentHTML('beforeend', articlesHTML);
    }
    
    // Show/hide load more button
    loadMoreBtn.style.display = endIndex < displayedArticles.length ? 'block' : 'none';
}

// Display more articles (for load more button)
function displayMoreArticles() {
    displayArticles(currentPage);
}

// Function to modify the article card creation (remove tags)
function createArticleCard(article) {
    // Format the date
    const pubDate = new Date(article.date);
    const formattedDate = pubDate.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
    
    // Create the HTML (without category and source badges)
    return `
        <div class="col-md-6 col-lg-4 mb-4">
            <div class="card article-card h-100">
                <div class="card-body">
                    <h5 class="card-title">${article.title}</h5>
                    <p class="card-text text-muted small">
                        <i class="bi bi-calendar3"></i> ${formattedDate} | 
                        <i class="bi bi-globe"></i> ${article.source}
                    </p>
                    <p class="card-text">${truncateText(article.description, 150)}</p>
                    <div class="mt-auto">
                        <a href="${article.url}" class="btn btn-sm btn-outline-primary" target="_blank">
                            Read More <i class="bi bi-box-arrow-up-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Helper function to truncate text
function truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// Debounce helper function
function debounce(func, wait) {
    let timeout;
    return function() {
        const context = this;
        const args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(() => {
            func.apply(context, args);
        }, wait);
    };
}
