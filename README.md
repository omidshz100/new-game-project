# New Game Project

This repository contains the web export of a **Godot Engine game** titled "New Game Project".

## Running the Game

To run the game, you need to serve the files using a local web server. Python's built-in HTTP server is a simple way to do this.

1.  **Start a web server:**
    Open a terminal or command prompt in the `production` directory and run one of the following commands:

    * **Python 3:** `python -m http.server`
    * **Python 2:** `python -m SimpleHTTPServer`

2.  **Open in your browser:**
    Open your web browser and navigate to `http://localhost:8000`. You may need to use a different port if 8000 is in use.

The game should start automatically.

## Project Structure

The important files for this web export are located in the `production` directory:

* **`New Game Project.html`**: This is the main entry point for the game. Open this file in your browser to start.
* **`New Game Project.js`**: This file contains the main JavaScript code for the Godot engine and the game logic.
* **`New Game Project.pck`**: This is the Godot package file, which contains all the game's assets and resources.
* **`New Game Project.wasm`**: This is the WebAssembly binary that runs the Godot engine in the browser.
* **`New Game Project.audio.position.worklet.js`** and **`New Game Project.audio.worklet.js`**: These files handle audio processing for the game in a separate thread for better performance.

The root directory also contains configuration files for the Godot project:

* **`.gitignore`**: This file specifies which files and directories to ignore in a Git repository.
* **`export_presets.cfg`**: This file contains the export settings for the web platform, as configured in the Godot editor. It specifies that the target platform is the Web and the main HTML file is `New Game Project.html`.

This project is set up to be run directly on a web server and is configured for a standard web export from the Godot Engine.
