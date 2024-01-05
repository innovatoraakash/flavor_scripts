#!/bin/bash

GRADLE_FILE_PATH="./android/app/build.gradle"
BACKUP_FILE_PATH="./android/app/build.gradle.bak"
CONTENT_TO_ADD=$(cat <<EOL
    apply from:'../config/build_types.gradle'
    apply from:'../config/product_flavors.gradle'
    apply from:'../config/signing_config.gradle'
EOL
)

# Check if the file exists
if [ ! -f "$GRADLE_FILE_PATH" ]; then
    echo "Error: Gradle file not found at $GRADLE_FILE_PATH"
    exit 1
fi

# Delete the existing backup file if it exists
if [ -f "$BACKUP_FILE_PATH" ]; then
    rm "$BACKUP_FILE_PATH"
    echo "Existing backup file deleted."
fi

# Make a new backup of the original file
cp "$GRADLE_FILE_PATH" "$BACKUP_FILE_PATH"

# Use awk to insert the content after 'android {' and before 'namespace'
awk -v content="$CONTENT_TO_ADD" '/android {/ {print; print content; next} 1' "$GRADLE_FILE_PATH" > "$GRADLE_FILE_PATH.tmp" && mv "$GRADLE_FILE_PATH.tmp" "$GRADLE_FILE_PATH"

echo "Content added successfully. New backup created at $BACKUP_FILE_PATH."
