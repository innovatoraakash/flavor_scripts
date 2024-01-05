#!/bin/bash

# Define the path to the Dart file
DART_FILE_PATH="./lib/config/flavor/flavor_config_data.dart"

# Define the code to be written to the Dart file
INPUT_CODE="enum EnvironmentType {
  sample(
    urlName: 'https://apple.mydynamicerp.com',
    companyCode: 121212,
    companyName: 'aaaa',
    appName:'sample'
  );
  final String urlName;
  final int companyCode;
  final String companyName;
  final String appName;
  const EnvironmentType({
    required this.urlName,
    required this.companyCode,
    required this.companyName,
     required this.appName,

  });
}"

# Function to create or update the Dart file
checkDartFlavorConfigFile() {
    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$DART_FILE_PATH")"

    # Check if the Dart file exists
    if [ ! -f "$DART_FILE_PATH" ]; then
        # Create the file and write the code if it doesn't exist
        echo "$INPUT_CODE" > "$DART_FILE_PATH"
        echo "Dart file created at '$DART_FILE_PATH'."

        # Set appropriate permissions for the Dart file
        chmod 644 "$DART_FILE_PATH"
        echo "Permissions set for '$DART_FILE_PATH'."
    else
        # File already exists
        echo "Dart file '$DART_FILE_PATH' already exists. No changes were made."
    fi
}

# Execute the function
checkDartFlavorConfigFile

