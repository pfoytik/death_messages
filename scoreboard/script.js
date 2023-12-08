// script.js

const scoreboard = document.querySelector('.scoreboard');

function updateScoreboard() {
    // Append a random query parameter to the URL to prevent caching
    const cacheBuster = new Date().getTime();
    const url = `your_data.json?${cacheBuster}`;

    // Fetch data from the JSON file
    fetch(url)
        .then(response => response.json())
        .then(data => {
            // Clear existing players on the scoreboard
            scoreboard.innerHTML = '';

            // Iterate through each player in the JSON data
            Object.entries(data).forEach(([playerName, counter]) => {
                // Create a player element
                const playerElement = document.createElement('div');
                playerElement.classList.add('player');

                // Set the player's name and counter value
                playerElement.innerHTML = `
                    <h3>${playerName}</h3>
                    <p>Counter: ${counter}</p>
                `;

                // Append the player element to the scoreboard
                scoreboard.appendChild(playerElement);
            });
        })
        .catch(error => console.error('Error fetching data:', error));
}

// Update the scoreboard initially and set up periodic updates (every 5 seconds in this example)
updateScoreboard();
setInterval(updateScoreboard, 5000);
