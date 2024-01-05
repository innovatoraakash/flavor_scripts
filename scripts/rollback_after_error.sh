#!/bin/bash

# Define paths
PRODUCT_FLAVOR_GRADLE_PATH="./android/config/product_flavors.gradle"
dart_file=$(find . -name "flavor_config.dart")
BUILD_TYPES_FILE_PATH="./android/config/build_types.gradle"

if [ -z "$dart_file" ]; then
    # File not found
    echo -e "${RED}flavor_config.dart not found.\nPlease rename your file containing EnvironmentType to flavor_config.dart, or run flavor setup.${NC}"
    exit
fi
# Define backup paths
DART_FILE_BACKUP_PATH="${FLAVOR_CONFIG_FILE}.bak"
GRADLE_FILE_BACKUP_PATH="${PRODUCT_FLAVOR_GRADLE_PATH}.bak"
BUILD_TYPES_FILE_BACKUP_PATH="${BUILD_TYPES_FILE_PATH}.bak"

# Function to rollback changes
rollback_changes() {
    echo "Rolling back changes..."

    for file in "$DART_FILE_BACKUP_PATH" "$GRADLE_FILE_BACKUP_PATH" "$BUILD_TYPES_FILE_BACKUP_PATH"; do
        if [ -f "$file" ]; then
            original_file="${file%.bak}"
            mv "$file" "$original_file"
            echo "Reverted changes in $original_file."
        else
            echo "Backup file $file does not exist. No reversion possible."
        fi
    done
  
delete_directory

    echo "Rollback completed."
}

# Function to terminate the script and ask for rollback
terminate_script_and_rollback() {
    read -p "Do you want to rollback changes? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        rollback_changes
    fi
    echo "Terminating the script."
    exit
}

# Function to check for errors and potentially initiate rollback
check_error_and_rollback() {
    if [ $? -ne 0 ]; then
        echo "An error occurred."
        terminate_script_and_rollback
    fi
}


delete_directory() {
    ANDROID_ICON_PATH="./android/app/src/$flavorName/"
    IOS_ICON_PATH="./ios/Runner/Assets.xcassets/AppIcon-$flavorName.appiconset/"

      echo "android path :$ANDROID_ICON_PATH"
         echo "Ios path :$IOS_ICON_PATH"

    # Check if flavorName is empty
    if [ -z "$flavorName" ]; then
        echo "Flavor name is empty. No folder to delete."
        exit
        return
    fi

    # Check and delete Android directory
    if [ -d "$ANDROID_ICON_PATH" ]; then
        echo "Deleting directory: $ANDROID_ICON_PATH"
        rm -rf "$ANDROID_ICON_PATH"  # Delete the directory and its contents
    else
        echo "Directory not found: $ANDROID_ICON_PATH" 
        # Directory does not exist
    fi

    # Check and delete iOS directory
    if [ -d "$IOS_ICON_PATH" ]; then
        echo "Deleting directory: $IOS_ICON_PATH"
        rm -rf "$IOS_ICON_PATH"  # Delete the directory and its contents
    else
        echo "Directory not found: $IOS_ICON_PATH" 
        # Directory does not exist
    fi
}

# Example usage:
# delete_directory "/path/to/directory"



delete_backup_files() {
    echo "Deleting backup files..."

    # Delete the backup files if they exist
    if [ -f "$DART_FILE_BACKUP_PATH" ]; then
        rm -f "$DART_FILE_BACKUP_PATH"
        echo "Deleted backup file $DART_FILE_BACKUP_PATH."
    else
        echo "Backup file $DART_FILE_BACKUP_PATH does not exist. No deletion needed."
    fi

    if [ -f "$GRADLE_FILE_BACKUP_PATH" ]; then
        rm -f "$GRADLE_FILE_BACKUP_PATH"
        echo "Deleted backup file $GRADLE_FILE_BACKUP_PATH."
    else
        echo "Backup file $GRADLE_FILE_BACKUP_PATH does not exist. No deletion needed."
    fi

    if [ -f "$BUILD_TYPES_FILE_BACKUP_PATH" ]; then
        rm -f "$BUILD_TYPES_FILE_BACKUP_PATH"
        echo "Deleted backup file $BUILD_TYPES_FILE_BACKUP_PATH."
    else
        echo "Backup file $BUILD_TYPES_FILE_BACKUP_PATH does not exist. No deletion needed."
    fi

    echo "Backup file deletion completed."
}

# Example usage
# delete_backup_files

# Example usage (replace with your actual functional code)
# cp "$FLAVOR_CONFIG_FILE" "$DART_FILE_BACKUP_PATH"
# check_error_and_rollback
# [perform other operations here]
# check_error_and_rollback

# Add other functions and logic here...

# Start the script
# ...

