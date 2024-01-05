#!/bin/bash
# Get the full path of the current script
SCRIPT_PATH=$(realpath "$0")

# Extract the directory from the full path
BASE_DIR=$(dirname "$SCRIPT_PATH")
# Function to set up flavor
setup_flavor() {
    echo "Setting up new flavor..."
   # Call scripts with the base directory
    "$BASE_DIR/scripts/create_flavor_gradle.sh"
    "$BASE_DIR/scripts/create_buildtype.sh"
    "$BASE_DIR/scripts/download_master_key.sh"
    "$BASE_DIR/scripts/create_signin_config.sh"
    "$BASE_DIR/scripts/add_file_path_to_build_gradle.sh"
    "$BASE_DIR/scripts/create_flavor_config_dart_file.sh"
    "$BASE_DIR/scripts/create_Asset_Folder"

    echo "Flavor setup completed."
}

# Function to add a flavor
add_flavor() {
    echo "Adding a new flavor..."
    "$BASE_DIR/add_flavor.sh"
    echo "New flavor added."
}

# Ask user for their choice
echo "Please select an option:"
echo "1: Setup a flavor Folders"
echo "2: Add New Flavor"
read user_choice

# Based on the choice, call the respective function
case $user_choice in
    1)
        setup_flavor
        ;;
    2)
        add_flavor
        ;;
    *)
        echo "Invalid input. Please enter '1' for setup or '2' for add."
        ;;
esac
