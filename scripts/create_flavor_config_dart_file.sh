#!/bin/bash

# Define the path to the Dart file
FLAVOR_CONFIG_FILE="./lib/config/flavor/flavor_config.dart"

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
    mkdir -p "$(dirname "$FLAVOR_CONFIG_FILE")"

    # Check if the Dart file exists
    if [ ! -f "$FLAVOR_CONFIG_FILE" ]; then
        # Create the file and write the code if it doesn't exist
        echo "$INPUT_CODE" > "$FLAVOR_CONFIG_FILE"
        echo "Dart file created at '$FLAVOR_CONFIG_FILE'."

        # Set appropriate permissions for the Dart file
        chmod 644 "$FLAVOR_CONFIG_FILE"
        echo "Permissions set for '$FLAVOR_CONFIG_FILE'."
    else
        # File already exists
        echo "Dart file '$FLAVOR_CONFIG_FILE' already exists. No changes were made."
    fi
}

# Execute the function
checkDartFlavorConfigFile

