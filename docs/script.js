// Add this function to your existing script.js file

/**
 * Updates the last updated timestamp in the UI
 */
function updateLastUpdatedTimestamp() {
    fetch('data/last_update.json')
        .then(response => {
            if (!response.ok) {
                throw new Error('Could not load last update time');
            }
            return response.json();
        })
        .then(data => {
            const lastUpdateElement = document.getElementById('last-update-time');
            if (lastUpdateElement) {
                const options = { 
                    year: 'numeric', 
                    month: 'short', 
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                };
                
                const formattedDate = new Date(data.timestamp).toLocaleDateString(undefined, options);
                lastUpdateElement.textContent = formattedDate;
            }
        })
        .catch(error => {
            console.error('Error fetching last update time:', error);
            // If we can't load the time, use current date as fallback
            const lastUpdateElement = document.getElementById('last-update-time');
            if (lastUpdateElement) {
                lastUpdateElement.textContent = new Date().toLocaleDateString();
            }
        });
}

// Call this function when the page loads
document.addEventListener('DOMContentLoaded', function() {
    // ...your existing initialization code...
    
    // Update the last update timestamp
    updateLastUpdatedTimestamp();
});
