// app.js - Main JavaScript file for AI News Daily
document.addEventListener('DOMContentLoaded', function() {
    // Main variables
    const newsContainer = document.getElementById('news-container');
    const allNewsView = document.getElementById('all-news-view');
    const aboutView = document.getElementById('about-view');
    const allNewsLink = document.getElementById('all-news-link');
    const aboutLink = document.getElementById('about-link');
    const loadMoreBtn = document.getElementById('load-more-btn');
    const searchInput = document.getElementById('search-input');
    const searchBtn = document.querySelector('.btn-outline-light');
    
    // Filter buttons
    const filterBtns = document.querySelectorAll('.filter-btn');
    
    // News data and display settings
    let allArticles = [];
    let filteredArticles = [];
    let currentFilter = 'all';
    let currentPage = 1;
    const articlesPerPage = 12;
    let searchQuery = '';
    
    // Navigation functions
    function showAllNewsView() {
        allNewsView.style.display = 'block';
        aboutView.style.display = 'none';
        allNewsLink.classList.add('active');
        aboutLink.classList.remove('active');
    }
    
    function showAboutView() {
        allNewsView.style.display = 'none';
        aboutView.style.display = 'block';
        allNewsLink.classList.remove('active');
        aboutLink.classList.add('active');
    }
    
    // Event listeners for navigation
    allNewsLink.addEventListener('click', function(e) {
        e.preventDefault();
        showAllNewsView();
    });
    
    aboutLink.addEventListener('click', function(e) {
        e.preventDefault();
        showAboutView();
    });
    
    // Event listeners for footer links (already in HTML)
    
    // Fetch news data
    async function fetchNews() {
        try {
            const response = await fetch('data/ai_news.csv');
            const csvData = await response.text();
            
            // Parse CSV
            const lines = csvData.split('\n');
            const headers = lines[0].split(',');
            
            // Process each line
            allArticles = lines.slice(1).map(line => {
                const values = line.split(',');
                const article = {};
                
                headers.forEach((header, index) => {
                    article[header] = values[index];
                });
                
                return article;
            }).filter(article => article.title && article.title.trim() !== '');
            
            // Set filtered articles to all
            filteredArticles = [...allArticles];
            
            // Update last updated date
            const lastUpdatedElement = document.getElementById('last-updated-date');
            if (lastUpdatedElement && allArticles.length > 0) {
                // Get the most recent date from the articles
                const dates = allArticles.map(article => new Date(article.date));
                const mostRecent = new Date(Math.max.apply(null, dates));
                const options = { year: 'numeric', month: 'long', day: 'numeric' };
                lastUpdatedElement.textContent = mostRecent.toLocaleDateString('en-US', options);
            }
            
            // Display the news
            displayNews();
            
        } catch (error) {
            console.error('Error fetching news:', error);
            newsContainer.innerHTML = `
                <div class="col-12 text-center py-5">
                    <p class="text-danger">Error loading articles. Please try again later.</p>
                </div>
            `;
        }
    }
    
    // Display news articles
    function displayNews() {
        // Clear loading indicator
        newsContainer.innerHTML = '';
        
        // Apply filtering
        let articlesToShow = filteredArticles;
        
        // Apply search if present
        if (searchQuery) {
            const query = searchQuery.toLowerCase();
            articlesToShow = articlesToShow.filter(article => 
                article.title.toLowerCase().includes(query) || 
                article.summary.toLowerCase().includes(query)
            );
        }
        
        // Apply category filter
        if (currentFilter !== 'all') {
            articlesToShow = articlesToShow.filter(article => {
                if (currentFilter === 'ai') return article.category.toLowerCase().includes('ai');
                if (currentFilter === 'machine-learning') return article.category.toLowerCase().includes('machine learning');
                if (currentFilter === 'gartner') return article.source.toLowerCase().includes('gartner');
                if (currentFilter === 'forrester') return article.source.toLowerCase().includes('forrester');
                return true;
            });
        }
        
        // Slice for pagination
        const paginatedArticles = articlesToShow.slice(0, currentPage * articlesPerPage);
        
        // Hide load more button if all articles are shown
        if (paginatedArticles.length >= articlesToShow.length) {
            loadMoreBtn.style.display = 'none';
        } else {
            loadMoreBtn.style.display = 'block';
        }
        
        // If no articles match, show a message
        if (paginatedArticles.length === 0) {
            newsContainer.innerHTML = `
                <div class="col-12 text-center py-5">
                    <p>No articles found matching your criteria.</p>
                </div>
            `;
            return;
        }
        
        // Display articles
        paginatedArticles.forEach(article => {
            // Clean the URL (remove quotes if present)
            const url = article.url.replace(/"/g, '');
            
            // Create card HTML
            const cardHtml = `
                <div class="col-md-4 mb-4">
                    <div class="card h-100">
                        <div class="card-body">
                            <h5 class="card-title">${article.title}</h5>
                            <h6 class="card-subtitle mb-2 text-muted">${article.source} - ${article.date}</h6>
                            <p class="card-text">${article.summary}</p>
                        </div>
                        <div class="card-footer bg-transparent">
                            <a href="${url}" class="btn btn-sm btn-primary" target="_blank">Read More</a>
                            <span class="badge bg-secondary float-end">${article.category}</span>
                        </div>
                    </div>
                </div>
            `;
            newsContainer.innerHTML += cardHtml;
        });
    }
    
    // Filter button functionality
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Update active state
            filterBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Set filter
            currentFilter = this.getAttribute('data-filter');
            currentPage = 1;
            
            // Display filtered news
            displayNews();
        });
    });
    
    // Load more button
    loadMoreBtn.addEventListener('click', function() {
        currentPage++;
        displayNews();
    });
    
    // Search functionality
    function performSearch() {
        searchQuery = searchInput.value.trim();
        currentPage = 1;
        displayNews();
        
        // If we're not on the all news view, switch to it
        if (aboutView.style.display !== 'none') {
            showAllNewsView();
        }
    }
    
    searchBtn.addEventListener('click', performSearch);
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            performSearch();
        }
    });
    
    // Initialize the app
    fetchNews();
});
