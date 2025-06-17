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
        
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                filterNewsBySearch(this.value);
            }
        });
    }
    
    // Set up search button
    const searchButton = document.getElementById('search-button');
    if (searchButton) {
        searchButton.addEventListener('click', function() {
            const searchInput = document.getElementById('search-input');
            if (searchInput) {
                filterNewsBySearch(searchInput.value);
            }
        });
    }
      // Set up view toggle buttons
    const cardsViewBtn = document.getElementById('cards-view-btn');
    const listViewBtn = document.getElementById('list-view-btn');
    
    if (cardsViewBtn && listViewBtn) {
        cardsViewBtn.addEventListener('click', function() {
            setViewMode('cards');
        });
        
        listViewBtn.addEventListener('click', function() {
            setViewMode('list');
        });
    }
    
    // Set up theme toggle
    const themeToggle = document.getElementById('theme-toggle');
    const themeIcon = document.getElementById('theme-icon');
    
    if (themeToggle) {
        // Check for saved theme preference
        const savedTheme = localStorage.getItem('theme');
        if (savedTheme) {
            document.documentElement.setAttribute('data-bs-theme', savedTheme);
            updateThemeIcon(savedTheme);
        }
        
        themeToggle.addEventListener('click', function() {
            const currentTheme = document.documentElement.getAttribute('data-bs-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            
            // Update theme
            document.documentElement.setAttribute('data-bs-theme', newTheme);
            
            // Save preference
            localStorage.setItem('theme', newTheme);
            
            // Update icon
            updateThemeIcon(newTheme);
        });
    }
    
    // Initialize with cards view
    setViewMode('cards');
});

// Initialize the application
function initApp() {
    // Load the last update timestamp
    loadLastUpdateTime();
    
    // Load the news data
    loadNewsData()
        .then(data => {
            // Store the data globally
            window.newsData = data;
            window.currentNewsItems = data; // For filtered results
            window.currentPage = 1;
            window.itemsPerPage = 10;
            
            // Display the news
            displayNews(data);
            
            // Initialize the visualization
            initVisualization(data);
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
function displayNews(newsItems, resetPage = true) {
    const container = document.getElementById('news-container');
    const loadingIndicator = document.getElementById('loading-indicator');
    const noResults = document.getElementById('no-results');
    const loadMoreBtn = document.getElementById('load-more-btn');
    
    if (loadingIndicator) {
        loadingIndicator.style.display = 'none';
    }
    
    if (!container) {
        console.error('News container not found!');
        return;
    }
    
    // Store current filtered items for pagination
    window.currentNewsItems = newsItems;
    
    if (resetPage) {
        window.currentPage = 1;
    }
    
    // Calculate pagination
    const startIndex = 0;
    const endIndex = window.currentPage * window.itemsPerPage;
    const paginatedItems = newsItems.slice(startIndex, endIndex);
    
    // Show/hide load more button
    if (loadMoreBtn) {
        if (endIndex >= newsItems.length) {
            loadMoreBtn.style.display = 'none';
        } else {
            loadMoreBtn.style.display = 'block';
        }
    }
    
    if (newsItems.length === 0) {
        if (noResults) {
            noResults.style.display = 'block';
        }
        container.innerHTML = '';
        return;
    }
    
    if (noResults) {
        noResults.style.display = 'none';
    }
    
    // Get current view mode
    const viewMode = localStorage.getItem('viewMode') || 'cards';
    
    // Clear container if resetting page
    if (resetPage) {
        container.innerHTML = '';
    }
      paginatedItems.forEach(item => {
        if (viewMode === 'cards') {
            container.appendChild(createCardView(item));
        } else {
            container.appendChild(createListView(item));
        }
    });
}

// Create card view element for an article
function createCardView(item) {
    const col = document.createElement('div');
    col.className = 'col-md-6 col-lg-4 mb-4';
    
    // Create card content
    const card = document.createElement('div');
    card.className = 'card h-100 news-card';
    
    // Create the card body
    const cardBody = document.createElement('div');
    cardBody.className = 'card-body';
    
    // Card title
    const title = document.createElement('h5');
    title.className = 'card-title mb-2';
    title.textContent = item.title;
    
    // Card subtitle with date and source
    const subtitle = document.createElement('h6');
    subtitle.className = 'card-subtitle mb-2 text-muted';
    subtitle.textContent = `${item.formattedDate} | Source: ${item.source}`;
    
    // Card text/description
    const description = document.createElement('p');
    description.className = 'card-text';
    description.textContent = item.description;
    
    // Read more link
    const link = document.createElement('a');
    link.href = item.url;
    link.className = 'btn btn-primary btn-sm';
    link.textContent = 'Read More';
    link.target = '_blank';
    
    // Assemble card
    cardBody.appendChild(title);
    cardBody.appendChild(subtitle);
    cardBody.appendChild(description);
    cardBody.appendChild(link);
    
    card.appendChild(cardBody);
    col.appendChild(card);
    
    return col;
}

// Create list view element for an article
function createListView(item) {
    const col = document.createElement('div');
    col.className = 'col-12 mb-2';
    
    // Create list item
    const card = document.createElement('div');
    card.className = 'card news-card';
    
    // Create the card body
    const cardBody = document.createElement('div');
    cardBody.className = 'card-body py-2';
    
    // Flex container for list view
    const flexContainer = document.createElement('div');
    flexContainer.className = 'd-flex justify-content-between align-items-center';
    
    // Left side: title and date
    const leftSide = document.createElement('div');
    leftSide.className = 'me-3';
    
    const title = document.createElement('h5');
    title.className = 'card-title mb-0';
    title.textContent = item.title;
    
    const subtitle = document.createElement('div');
    subtitle.className = 'text-muted small';
    subtitle.textContent = `${item.formattedDate} | ${item.source}`;
    
    leftSide.appendChild(title);
    leftSide.appendChild(subtitle);
    
    // Right side: read more
    const rightSide = document.createElement('div');
    rightSide.className = 'd-flex align-items-center';
    
    const link = document.createElement('a');
    link.href = item.url;
    link.className = 'btn btn-sm btn-outline-primary';
    link.textContent = 'Read';
    link.target = '_blank';
    
    // Add items to right side
    rightSide.appendChild(link);
    
    // Assemble the list item
    flexContainer.appendChild(leftSide);
    flexContainer.appendChild(rightSide);
    
    cardBody.appendChild(flexContainer);
    card.appendChild(cardBody);
    col.appendChild(card);
    
    return col;
}

// Get color class based on category
function getCategoryColor(category) {
    category = category.toLowerCase();
    
    if (category.includes('ai') || category === 'artificial intelligence') {
        return 'danger';
    } else if (category.includes('ml') || category === 'machine learning') {
        return 'primary';
    } else if (category.includes('research')) {
        return 'info';
    } else if (category.includes('business') || category.includes('industry')) {
        return 'success';
    } else if (category.includes('ethics') || category.includes('policy')) {
        return 'warning';
    } else {
        return 'secondary';
    }
}

// Set view mode (cards or list)
function setViewMode(mode) {
    // Save preference
    localStorage.setItem('viewMode', mode);
    
    // Update button states
    const cardsBtn = document.getElementById('cards-view-btn');
    const listBtn = document.getElementById('list-view-btn');
    
    if (cardsBtn && listBtn) {
        if (mode === 'cards') {
            cardsBtn.classList.add('active');
            listBtn.classList.remove('active');
        } else {
            cardsBtn.classList.remove('active');
            listBtn.classList.add('active');
        }
    }
    
    // Update container class
    const container = document.getElementById('news-container');
    if (container) {
        container.classList.remove('news-cards-view', 'news-list-view');
        container.classList.add(mode === 'cards' ? 'news-cards-view' : 'news-list-view');
    }
    
    // Redisplay news with current mode
    if (window.currentNewsItems) {
        displayNews(window.currentNewsItems);
    }
}

// Update theme toggle icon
function updateThemeIcon(theme) {
    const icon = document.getElementById('theme-icon');
    if (icon) {
        icon.className = theme === 'dark' ? 'bi bi-sun-fill' : 'bi bi-moon-fill';
    }
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
    document.getElementById('about-view').style.display = 'none';
    document.getElementById('all-news-view').style.display = 'block';
    
    // Reload data in case it was changed
    if (window.newsData) {
        displayNews(window.newsData);
    }
}

// Show about page
function showAboutPage() {
    document.getElementById('all-news-view').style.display = 'none';
    document.getElementById('about-view').style.display = 'block';
}

// Load more articles
document.addEventListener('DOMContentLoaded', function() {
    const loadMoreBtn = document.getElementById('load-more-btn');
    if (loadMoreBtn) {
        loadMoreBtn.addEventListener('click', function() {
            if (window.currentNewsItems && window.currentPage) {
                window.currentPage++;
                displayNews(window.currentNewsItems, false);
            }
        });
    }
});

// Load and display the last update timestamp
function loadLastUpdateTime() {
    fetch('data/last_update.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Could not load update timestamp');
            }
            return response.json();
        })
        .then(data => {
            // Format the timestamp in Central Standard Time (CST/CDT)
            // Parse as UTC, then display in America/Chicago
            const timestamp = new Date(data.timestamp.replace(' ', 'T') + 'Z');
            const options = {
                year: 'numeric',
                month: 'long',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true,
                timeZone: 'America/Chicago', // CST/CDT
                timeZoneName: 'short'
            };
            const formattedDate = timestamp.toLocaleString('en-US', options);
            // Update the last-updated-date element in the footer
            const lastUpdatedElement = document.getElementById('last-updated-date');
            if (lastUpdatedElement) {
                lastUpdatedElement.textContent = formattedDate;
            }
        })
        .catch(error => {
            console.warn('Error loading update timestamp:', error);            // Fall back to current date if we can't load the timestamp
            const options = { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                timeZoneName: 'short'
            };
            const currentDate = new Date().toLocaleDateString('en-US', options);
            
            const lastUpdatedElement = document.getElementById('last-updated-date');
            if (lastUpdatedElement) {
                lastUpdatedElement.textContent = currentDate;
            }
        });
}