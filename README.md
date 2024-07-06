# LemonWeb: AutoIt3 HTTP Server Proof of Concept

## Overview

This repository contains a proof of concept HTTP server called LemonWeb, written in AutoIt3. The primary purpose of this project is to demonstrate the capabilities of AutoIt3 in creating a basic HTTP server for educational and experimental purposes.

## Features

- Simple and lightweight HTTP server implementation.
- Handles basic HTTP requests.
- Handles PHP scripts.
- Serves static HTML content.
- Directory browsing and download.
- Easy to configure and extend.

## TODO
- POST requests not fully implemented, as I've lost interest.

## Requirements

- [AutoIt3](https://www.autoitscript.com/site/autoit/downloads/) installed on your system.

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/Clobie/autoit3-http-server.git
    cd autoit3-http-server
    ```

2. Ensure that AutoIt3 is installed on your system.

## Usage

1. Open the `LemonWeb.au3` script in AutoIt3 SciTE editor or any text editor.

2. Modify the configuration settings (e.g., port number, document root) as needed inside the LemonWeb.au3 file.

3. Run the script:

    - If using the SciTE editor, press `F5` to run the script.
    - Alternatively, right-click the script file and select "Run Script".

4. Open your web browser and navigate to `http://localhost/` (or the configured port) to see the server in action.
