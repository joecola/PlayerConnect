# PlayerConnect Module

## Overview
The PlayerConnect module for Drupal 11 allows for the management of player data through a RESTful API. This module enables anonymous users to create and update Player nodes, which include player statistics such as current scores and high scores.

## Features
- Create a content type called "Player" with the following fields:
  - Player name (node title)
  - Current score (number)
  - High score (number)
  - Player info (text field)
  
- RESTful API for managing Player nodes:
  - Anonymous users can add and update Player nodes.
  - Checks for existing Player nodes based on the title name to determine whether to create a new node or update an existing one.
  - Updates the high score if the current score exceeds the previous high score.

## Installation
1. Download the PlayerConnect module and place it in the `modules/custom` directory of your Drupal installation.
2. Enable the module using the Drupal admin interface or Drush:
   ```
   drush en playerconnect
   ```
3. The module will automatically create the "Player" content type and the necessary fields upon installation.

## Usage
- To create a new Player node or update an existing one, send a RESTful request to the PlayerResource endpoint with the following JSON payload:
  ```json
  {
    "playerconnect_name": "Player Name",
    "playerconnect_current_score": 100,
    "playerconnect_info": "Some player information"
  }
  ```

## Development
- The module is structured with the following key components:
  - **Controller**: Manages the logic for creating and updating Player nodes.
  - **REST Resource**: Implements the RESTful API for Player nodes.

## Dependencies
- This module requires the following dependencies:
  - Drupal core version 11.x
  - Any additional modules required for RESTful services.

## Contributing
Contributions to the PlayerConnect module are welcome. Please submit issues or pull requests on the module's repository.

## License
This module is licensed under the GPL-2.0-or-later license.