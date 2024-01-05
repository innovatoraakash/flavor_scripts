#!/bin/bash

# Define the path to the Gradle build types file
BUILD_TYPES_FILE_PATH="./android/config/build_types.gradle"

# Define the Gradle content
GRADLE_CONTENT="apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

apply from:'../config/signing_config.gradle'
apply from:'../config/product_flavors.gradle'

android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            productFlavors.sample.signingConfig signingConfigs.releaseSigningConfig
        }
    }
}"

# Function to create or update the Gradle build types file
checkGradleBuildTypeFile() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$BUILD_TYPES_FILE_PATH")"

    # Check if the Gradle file exists
    if [ -f "$BUILD_TYPES_FILE_PATH" ]; then
        # Check if the file already contains the expected content
        if grep -qF "$GRADLE_CONTENT" "$BUILD_TYPES_FILE_PATH"; then
            echo "Gradle file '$BUILD_TYPES_FILE_PATH' already exists with the expected content."
        else
            # Append the code into the Gradle file if it exists but doesn't have the expected content
            echo "$GRADLE_CONTENT" >> "$BUILD_TYPES_FILE_PATH"
            echo "Code appended to existing Gradle file '$BUILD_TYPES_FILE_PATH'."
        fi
    else
        # Create the Gradle file and write the content if it doesn't exist
        echo "$GRADLE_CONTENT" > "$BUILD_TYPES_FILE_PATH"
        echo "Gradle file '$BUILD_TYPES_FILE_PATH' created and code written."

        # Set appropriate permissions to the Gradle file
        chmod 644 "$BUILD_TYPES_FILE_PATH"
        echo "Permissions set for '$BUILD_TYPES_FILE_PATH'."
    fi
}

# Execute the function
checkGradleBuildTypeFile
