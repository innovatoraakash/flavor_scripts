# #!/bin/bash

# Replace 'YOUR_FILE_ID' with the actual file ID from Google Drive
FILE_ID="1AZO02DJVcR0RTCzCJzmP5ItLszKWQKiR"

# Replace 'YOUR_DESTINATION_FOLDER' with the destination folder where you want to save the file
DESTINATION_FOLDER="./android/config/keys/"

# Function to display an error message and exit
function display_error {
    echo "Error: $1"
    exit 1
}

# Function to download the file
function download_file {
    local download_url="https://drive.google.com/uc?id=$FILE_ID"
    local output_file="$DESTINATION_FOLDER/master.jks"

    # Download the file using curl
    curl -L -o "$output_file" "$download_url" || display_error "Failed to download the file."
}

# Create destination folder if it doesn't exist
mkdir -p "$DESTINATION_FOLDER" || display_error "Failed to create destination folder."

# Download the file
download_file

echo "File downloaded and saved to '$DESTINATION_FOLDER/master.jks'."
