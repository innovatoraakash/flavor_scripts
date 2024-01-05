#!/bin/bash

# Define the path and content of the signing config file
SIGNING_CONFIG_FILE_PATH="./android/config/signing_config.gradle"
SIGNING_CONFIG_CONTENT="apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'

android {
    def commonPassword = 'Dynamic@123'
    final masterAlias = 'master'
    signingConfigs {
        releaseSigningConfig {
            storeFile file('../keys/master_key/master.jks')
            storePassword commonPassword
            keyAlias masterAlias
            keyPassword commonPassword
        }
    }
}"

# Function to check and create the signing config file
checkSigninConfigfile() {
  # Create the directory path if it doesn't exist
  mkdir -p "$(dirname "$SIGNING_CONFIG_FILE_PATH")"

  # Check if the signing config file exists
  if [ -e "$SIGNING_CONFIG_FILE_PATH" ]; then
    # Check if the file already contains the expected content
    if grep -qF "$SIGNING_CONFIG_CONTENT" "$SIGNING_CONFIG_FILE_PATH"; then
      echo "Signing config Gradle file '$SIGNING_CONFIG_FILE_PATH' already exists with the expected content."
    else
      # Append the content if the file exists but doesn't have the expected content
      echo "$SIGNING_CONFIG_CONTENT" >> "$SIGNING_CONFIG_FILE_PATH"
      echo "Code appended to existing signing config Gradle file '$SIGNING_CONFIG_FILE_PATH'."
    fi
  else
    # Create the file and write the content if it doesn't exist
    echo "$SIGNING_CONFIG_CONTENT" > "$SIGNING_CONFIG_FILE_PATH"
    echo "Signing config Gradle file '$SIGNING_CONFIG_FILE_PATH' created and code written."
  fi

  # Set full permissions to the signing config file
  chmod 777 "$SIGNING_CONFIG_FILE_PATH"
  echo "Full permissions granted to '$SIGNING_CONFIG_FILE_PATH'."
}

# Execute the function
checkSigninConfigfile
