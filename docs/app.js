// AI News Daily - Main JavaScript application
document.addEventListener('DOMContentLoaded', function() {
    // Initialize the application
    initApp();

    // Set up event listeners for navigation
    document.getElementById('all-news-link').addEventListener('click', function(e) {
        e.preventDefault();
        showAllNews();
    });

    document.getElementById('about-link').addEventListener('click', function(e) {
        e.preventDefault();
        showAboutPage();
    });

    // Set up search functionality
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            filterNewsBySearch(this.value);
        });
    }

    // Set up category filter functionality
    const categorySelect = document.getElementById('category-filter');
    if (categorySelect) {
        categorySelect.addEventListener('change', function() {
            filterNewsByCategory(this.value);
        });
    }
});

// Initialize the application
function initApp() {
    // Load the news data
    loadNewsData()
        .then(data => {
            // Store the data globally
            window.newsData = data;
            
            // Display the news
            displayNews(data);
            
            // Initialize the visualization
            initVisualization(data);
            
            // Populate category filter
            populateCategoryFilter(data);
        })
        .catch(error => {
            console.error('Error loading news data:', error);
            document.getElementById('loading-indicator').style.display = 'none';
            document.getElementById('news-container').innerHTML = 
                '<div class="alert alert-danger">Error loading news data. Please try again later.</div>';
        });
}

// Load news data from CSV
function loadNewsData() {
    return new Promise((resolve, reject) => {
        d3.csv('data/ai_news.csv')
            .then(data => {
                // Process and sort the data
                const processedData = processNewsData(data);
                resolve(processedData);
            })
            .catch(error => {
                console.error('Error fetching CSV:', error);
                reject(error);
            });
    });
}

// Process and format the news data
function processNewsData(data) {
    return data.map(item => {
        // Format date
        const date = new Date(item.date);
        const formattedDate = date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
        
        return {
            ...item,
            formattedDate: formattedDate,
            date: date, // Store the actual date object for sorting
            category: item.category ? item.category.trim() : 'uncategorized'
        };
    }).sort((a, b) => b.date - a.date); // Sort by date (newest first)
}

// Display news in the news container
function displayNews(newsItems) {
    const container = document.getElementById('news-container');
    const loadingIndicator = document.getElementById('loading-indicator');
    
    if (loadingIndicator) {
        loadingIndicator.style.display = 'none';
    }
    
    if (!container) {
        console.error('News container not found!');
        return;
    }
    
    if (newsItems.length === 0) {
        container.innerHTML = '<div class="alert alert-info">No news items found.</div>';
        return;
    }
    
    let html = '';
    
    newsItems.forEach(item => {
        html += `
        <div class="news-card card mb-3" data-category="${item.category}">
            <div class="card-body">
                <div class="d-flex justify-content-between">
                    <h5 class="card-title">${item.title}</h5>
                    <span class="badge badge-primary">${item.category}</span>
                </div>
                <h6 class="card-subtitle mb-2 text-muted">${item.formattedDate} | Source: ${item.source}</h6>
                <p class="card-text">${item.description}</p>
                <a href="${item.url}" class="btn btn-primary btn-sm" target="_blank">Read More</a>
            </div>
        </div>
        `;
    });
    
    container.innerHTML = html;
}

// Initialize data visualization
function initVisualization(data) {
    // Create category count visualization
    createCategoryChart(data);
    
    // Create timeline visualization
    createTimelineChart(data);
}

// Create a chart showing news by category
function createCategoryChart(data) {
    const categoryChart = document.getElementById('category-chart');
    if (!categoryChart) return;
    
    // Count items by category
    const categoryCounts = {};
    data.forEach(item => {
        const category = item.category || 'uncategorized';
        if (categoryCounts[category]) {
            categoryCounts[category]++;
        } else {
            categoryCounts[category] = 1;
        }
    });
    
    // Prepare data for chart
    const categories = Object.keys(categoryCounts);
    const counts = Object.values(categoryCounts);
    const backgroundColors = categories.map((_, i) => 
        `hsl(${(i * 360 / categories.length) % 360}, 70%, 60%)`
    );
    
    // Create chart
    new Chart(categoryChart, {
        type: 'bar',
        data: {
            labels: categories,
            datasets: [{
                label: 'Number of News Items',
                data: counts,
                backgroundColor: backgroundColors
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                },
                title: {
                    display: true,
                    text: 'News by Category'
                }
            }
        }
    });
}

// Create a timeline chart
function createTimelineChart(data) {
    const timelineChart = document.getElementById('timeline-chart');
    if (!timelineChart) return;
    
    // Group data by date
    const dateGroups = {};
    data.forEach(item => {
        const dateStr = item.date.toISOString().split('T')[0];
        if (dateGroups[dateStr]) {
            dateGroups[dateStr]++;
        } else {
            dateGroups[dateStr] = 1;
        }
    });
    
    // Sort dates
    const sortedDates = Object.keys(dateGroups).sort();
    const counts = sortedDates.map(date => dateGroups[date]);
    
    // Create chart
    new Chart(timelineChart, {
        type: 'line',
        data: {
            labels: sortedDates.map(date => new Date(date).toLocaleDateString()),
            datasets: [{
                label: 'News Items',
                data: counts,
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 2,
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                title: {
                    display: true,
                    text: 'News Timeline'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Number of News Items'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Date'
                    }
                }
            }
        }
    });
}

// Populate category filter dropdown
function populateCategoryFilter(data) {
    const categorySelect = document.getElementById('category-filter');
    if (!categorySelect) return;
    
    // Get unique categories
    const categories = new Set();
    data.forEach(item => {
        categories.add(item.category || 'uncategorized');
    });
    
    // Add options to select
    let options = '<option value="all">All Categories</option>';
    categories.forEach(category => {
        options += `<option value="${category}">${category}</option>`;
    });
    
    categorySelect.innerHTML = options;
}

// Filter news by search query
function filterNewsBySearch(query) {
    if (!window.newsData) return;
    
    query = query.toLowerCase();
    
    if (!query) {
        displayNews(window.newsData);
        return;
    }
    
    const filtered = window.newsData.filter(item => 
        item.title.toLowerCase().includes(query) || 
        item.description.toLowerCase().includes(query) ||
        item.source.toLowerCase().includes(query) ||
        item.category.toLowerCase().includes(query)
    );
    
    displayNews(filtered);
}

// Filter news by category
function filterNewsByCategory(category) {
    if (!window.newsData) return;
    
    if (category === 'all') {
        displayNews(window.newsData);
        return;
    }
    
    const filtered = window.newsData.filter(item => 
        item.category === category
    );
    
    displayNews(filtered);
}

// Show all news (main view)
function showAllNews() {
    document.getElementById('about-section').style.display = 'none';
    document.getElementById('main-content').style.display = 'block';
    
    // Reload data in case it was changed
    if (window.newsData) {
        displayNews(window.newsData);
    }
}

// Show about page
function showAboutPage() {
    document.getElementById('main-content').style.display = 'none';
    document.getElementById('about-section').style.display = 'block';
}