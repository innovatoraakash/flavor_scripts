#!/bin/bash

# Define the path to the Gradle file
GRADLE_FILE_PATH="./android/config/product_flavors.gradle"

# Define the code to be written to the Gradle file
CODE_TO_WRITE="apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

android {
    flavorDimensions 'version'
    productFlavors {
        sample {
            dimension 'version'
            applicationIdSuffix '.apple'
            resValue 'string', 'app_name', 'aaa'
            buildConfigField 'String', 'APP_BASE_URL', 'https://apple.mydynamicerp.com'
        }
    }
}"

# Function to create or update the Gradle file
createOrUpdateGradleFile() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$GRADLE_FILE_PATH")"

    # Check if the Gradle file exists
    if [ ! -f "$GRADLE_FILE_PATH" ]; then
        # Create the file and write the code if it doesn't exist
        echo "$CODE_TO_WRITE" > "$GRADLE_FILE_PATH"
        echo "Gradle file created at '$GRADLE_FILE_PATH'."
    else
        # File already exists
        echo "The file $GRADLE_FILE_PATH already exists. No changes were made."
        # If you want to overwrite or update the existing file, you can handle it here.
    fi

    # Set full permissions to the Gradle file
    chmod 777 "$GRADLE_FILE_PATH"
    echo "Full permissions granted to '$GRADLE_FILE_PATH'."
}

# Execute the function
createOrUpdateGradleFile

# Grant full permission to the script itself
chmod 777 $0
