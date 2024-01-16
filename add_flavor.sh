#!/bin/bash
export LC_ALL=C.UTF-8
# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define paths
PRODUCT_FLAVOR_GRADLE_PATH="./android/config/product_flavors.gradle"
FLAVOR_CONFIG_FILE=$(find . -name "flavor_config.dart")
BUILD_TYPES_FILE_PATH="./android/config/build_types.gradle"
SignInConfig_file_Path="./android/config/signing_config.gradle"
if [ -z "$FLAVOR_CONFIG_FILE" ]; then
    # File not found
    echo -e "${RED}flavor_config.dart not found.\nPlease rename your file containing EnvironmentType to flavor_config.dart, or run flavor setup.${NC}"
fi


# Path to your pubspec.yaml
PUBSPEC="./pubspec.yaml"

# Extract the name value
projectName=$(grep '^name:' "$PUBSPEC" | cut -d':' -f2 | xargs)

echo "Project name : $projectName"

# # Define backup paths
DART_FILE_BACKUP_PATH="${FLAVOR_CONFIG_FILE}.bak"
GRADLE_FILE_BACKUP_PATH="${PRODUCT_FLAVOR_GRADLE_PATH}.bak"
BUILD_TYPES_FILE_BACKUP_PATH="${BUILD_TYPES_FILE_PATH}.bak"
SignInConfig_file_BACKUP_Path="${SignInConfig_file_Path}.bak"
ANDROID_ICON_PATH="./android/app/src/$flavorName"
IOS_ICON_PATH="./ios/Runner/Assets.xcassets/AppIcon-$flavorName.appiconset"



assetPath="./flavor_icon/"



Android_Icon_Path="./android/app/src/$flavorName"
Ios_Icon_Path="./ios/Runner/Assets.xcassets/AppIcon-$flavorName.appiconset"



# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}
trim() {
    local var="$*"
    # Remove leading spaces
    var="${var#"${var%%[![:space:]]*}"}"
    # Remove trailing spaces
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}


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
  
    delete_directory "$ANDROID_ICON_PATH"
    delete_directory "$IOS_ICON_PATH"

    echo "Rollback completed."
}

# Function to terminate the script and ask for rollback
terminate_script_and_rollback() {
    read -p "Do you want to rollback changes? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        rollback_changes
    fi
    echo "Terminating the script. Backup files created at for ${YELLOW}build_types.gradle${NC} and ${YELLOW}product_flavor.gradle${NC} inside ${YELLOW}android/config${NC} "
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



# Function to read user inputs
read_user_inputs() {
    # This function collects user inputs for setting up a new software flavor, application name, URL, company code, and company name.

    while true; do
        # Prompt for flavor name input
        read -p "Enter new flavor name: " flavorName
        flavorName=$(trim "$flavorName")  # Trims whitespace from input

        # Convert first letter to lowercase for consistency
        flavorName="$(tr '[:upper:]' '[:lower:]' <<< ${flavorName:0:1})${flavorName:1}"

        # Validate input for flavor name
        if [[ -z "$flavorName" ]]; then
            echo "Error: Flavor name is required and cannot be empty."
            continue
        elif [[ "$flavorName" =~ \  ]]; then
            echo "Error: Flavor name should not contain spaces."
            continue
        elif [[ "$flavorName" =~ ^[0-9] ]] || [[ "$flavorName" =~ [0-9]$ ]]; then
            echo "Error: Flavor name cannot start or end with a number."
            continue
        fi

        # Check if flavor name already exists in the Dart file
       if grep -q "$flavorName(" "$FLAVOR_CONFIG_FILE"; then
    echo "Flavor '$flavorName' already exists. Choose an action:"
    select opt in "Create New Flavor" "Abort"; do
        case $opt in
            "Create New Flavor") 
                continue 2 ;;  # Ask for a new flavor name
            "Abort") 
                echo "Operation aborted by user.";  
                exit;;  # Exit the script
            *) 
                echo "Invalid option. Please select a valid action (1 or 2)." ;;
        esac
    done
else
    break  # Valid flavor name entered
fi
    done

    # Prompt for application name input
    while true; do
        read -p "Enter App Name: " appName
        appName=$(trim "$appName")  # Trims whitespace from input

        if [[ -z "$appName" ]]; then
            echo "Error: Application name is required and cannot be empty."
            continue
        fi
        break  # Valid app name entered
    done
     # Prompt for company name input
    while true; do
        read -p "Enter Company Name: " companyName
        if [[ -z "$companyName" ]]; then
            echo "Error: Company Name is required and cannot be empty."
            continue
        fi
        break  # Valid company name entered
    done

    # Prompt for company code input
    while true; do
        read -p "Enter Company Code: " companyCode
        companyCode=$(trim "$companyCode")  # Trims whitespace from input

        if ! [[ "$companyCode" =~ ^[0-9]+$ ]]; then
            echo "Error: Company Code must be a numeric value."
            continue
        fi

        # Check if the code exists in the Dart file
        if grep -q "companyCode: $companyCode" "$FLAVOR_CONFIG_FILE"; then
            echo "Code '$companyCode' already exists for flavor '$flavorName'. Choose an action:"
            select opt in "Enter a New Code" "Exit Script" "Show Match"; do
                case $opt in
                    "Enter a New Code") break ;;  # Ask for a new code
                    "Exit Script") echo "Operation aborted by user."; exit ;;  # Exit script
                    "Show Match")
                        echo "Matching enum details:"
                        awk -v code="$companyCode" -v RS= -v FS="\n" '/EnvironmentType/ && /companyCode: '"$companyCode"'/ {print $0}' "$FLAVOR_CONFIG_FILE"
                        continue 2  # Continue at the beginning of the outer loop
                        ;;
                    *) echo "Invalid option. Please select a valid action." ;;
                esac
            done
        else
            break  # Valid company code entered
        fi
    done

    # Prompt for bundle identifier
   
        read -p "Enter Bundle Identifier Id (leave blank for default): " bundleId
        bundleId=$(trim "$bundleId")  # Trims whitespace from input

        # if ! [[ "$bundleId" =~ ^[0-9]+$ ]]; then
        #     echo "Error: Company Code must be a numeric value."
        #     continue
        # fi
        
     
    

    # Choose URL Extension Type
    echo "Select URL Extension Type:"
    select extensionType in ".mydynamicerp.com" ".dynamicerp.online" ".dynamicerp.com" ".dealersathi.com" "Custom"; do
        case $extensionType in
            ".mydynamicerp.com" | ".dynamicerp.online" | ".dynamicerp.com" | ".dealersathi.com")
                urlName="https://$flavorName$extensionType"
                echo "URL saved: $urlName"
                break  # URL with selected extension saved
                ;;
            "Custom")
                # Prompt for custom URL input
                while true; do
                    read -p "Enter Custom URL ( without Http: ): " customUrl
                    if [[ -z "$customUrl" ]]; then
                        echo "Error: Custom URL is required and cannot be empty."
                        continue
                    fi
                      # Trim https:// if present
            customUrl="${customUrl#https://}"

            # Trim http:// if present
            customUrl="${customUrl#http://}"

            # Trim www. if present
            customUrl="${customUrl#www.}"
                    urlName="https://$customUrl"
                    echo "Custom URL saved: $urlName"
                    break  # Custom URL saved
                done
                break
                ;;
            *) echo "Invalid selection. Please choose a valid extension or 'Custom'." ;;
        esac
    done




   

    # End of the function
}




add_env_type_in_dart() {
    # Check if all required arguments are provided
    if [ -z "$flavorName" ] || [ -z "$urlName" ] || [ -z "$companyCode" ] || [ -z "$companyName" ]; then
        echo "ERROR: Missing arguments. All arguments must be provided."
        return 1
    fi
    
    # Define the new enum value

    if [ -n "$bundleId" ]; then
        newEnumValue="$flavorName(
            urlName: '$urlName',
            companyCode: $companyCode,
            companyName: '$companyName',
            appName: '$appName',
            bundleId: '$bundleId',
        ),"
    else
        newEnumValue="$flavorName(
            urlName: '$urlName',
            companyCode: $companyCode,
            companyName: '$companyName',
            appName: '$appName',
        ),"
    fi

    # Backup the original Dart file
    cp "$FLAVOR_CONFIG_FILE" "${FLAVOR_CONFIG_FILE}.bak"

    # Check if the enum value already exists
    if grep -q "$flavorName(" "$FLAVOR_CONFIG_FILE"; then
        echo "Enum value '$flavorName' already exists. Choose an option:"
        select opt in "Override" "Abort"; do
            case $opt in
                "Override")
                    # Override the existing enum value
                    sed -i "/$flavorName(/c\\$newEnumValue" "$FLAVOR_CONFIG_FILE"
                    echo "Enum value '$flavorName' overridden successfully."
                    break
                    ;;
                "Abort")
                    # User chooses to abort: Delete backup and exit
                    echo "Operation aborted by user."
                    rm -f "${FLAVOR_CONFIG_FILE}.bak"
                    echo "Deleted backup file ${FLAVOR_CONFIG_FILE}.bak."
                    return 0
                    ;;
                *)
                    echo "Invalid option. Please choose 'Override' or 'Abort'."
                    ;;
            esac
        done
    else
        # Add the new enum value
        echo "$newEnumValue" > temp_enum_value.txt

        # Find the insertion point for the new enum value
        insertLine=$(grep -n 'enum EnvironmentType {' "$FLAVOR_CONFIG_FILE" | cut -d: -f1)
        if [ -z "$insertLine" ]; then
            echo "ERROR: Enum 'EnvironmentType' not found in $FLAVOR_CONFIG_FILE."
            mv "${FLAVOR_CONFIG_FILE}.bak" "$FLAVOR_CONFIG_FILE"
            rm temp_enum_value.txt
            return 1
        fi

        # Insert the new enum value and clean up
        sed -i "${insertLine}r temp_enum_value.txt" "$FLAVOR_CONFIG_FILE"
        rm temp_enum_value.txt

        # Verify if the new enum value was added successfully
        if grep -q "$flavorName(" "$FLAVOR_CONFIG_FILE"; then
            echo "New enum value '$flavorName' added successfully to $FLAVOR_CONFIG_FILE"
             
        else
            echo "ERROR: Failed to add the new enum value '$flavorName'. Restoring from backup."
            mv "${FLAVOR_CONFIG_FILE}.bak" "$FLAVOR_CONFIG_FILE"
            return 1
        fi
    fi
    dart format $FLAVOR_CONFIG_FILE
}




# Function to insert the new flavor block into the gradle file
# Function to insert the new flavor block into the gradle file
add_flavor_detail_in_gradle() {
    # Define the new flavor block
    newFlavorBlock="
        $flavorName {
            dimension \"version\"
            applicationIdSuffix \".$flavorName\"
            resValue \"string\", \"application_name\", \"$appName\"
        }
    "

    # Check if the flavor already exists in the Gradle file
    if grep -q "$flavorName {" "$PRODUCT_FLAVOR_GRADLE_PATH"; then
        echo "Flavor '$flavorName' already exists in the Gradle file. Please choose an action:"
        select opt in "Create New Flavor" "Abort Operation"; do
            case $opt in
                "Create New Flavor")
                    # Restart the process for a new flavor
                    read_user_inputs
                    create_new_flavor_block
                    add_flavor_detail_in_gradle
                    break
                    ;;
                "Abort Operation")
                    # Abort the operation
                    echo "Operation aborted by user. No changes made."
                    return 0
                    ;;
                *)
                    echo "Invalid option. Please choose 'Create New Flavor' or 'Abort Operation'."
                    ;;
            esac
        done
    else
        # Backup the original Gradle file before making changes
        cp "$PRODUCT_FLAVOR_GRADLE_PATH" "${PRODUCT_FLAVOR_GRADLE_PATH}.bak"

        # Insert the new flavor block into the Gradle file
        echo "$newFlavorBlock" | awk -v flavorBlock="$newFlavorBlock" '/productFlavors {/ {print; print flavorBlock; next}1' "$PRODUCT_FLAVOR_GRADLE_PATH" > temp.gradle
        mv temp.gradle "$PRODUCT_FLAVOR_GRADLE_PATH"

        # Check if the new flavor was added successfully
        if grep -q "$flavorName" "$PRODUCT_FLAVOR_GRADLE_PATH"; then
            echo "New flavor '$flavorName' successfully added to the Gradle file."
            # Backup file is retained for safety
        else
            # Handle failure to add the new flavor
            echo "Failed to add new flavor '$flavorName'. Restoring original Gradle file."
           # mv "${PRODUCT_FLAVOR_GRADLE_PATH}.bak" "$PRODUCT_FLAVOR_GRADLE_PATH"
            rollback_changes
        fi
    fi
}



# Function to add new build type configuration
add_build_type_configuration() {
    # Verify if BUILD_TYPES_FILE_PATH is set
    if [ -z "${BUILD_TYPES_FILE_PATH}" ]; then
        echo "Error: BUILD_TYPES_FILE_PATH is not set."
        return 1
    fi

    # Verify if the file exists
    if [ ! -f "${BUILD_TYPES_FILE_PATH}" ]; then
        echo "Error: File ${BUILD_TYPES_FILE_PATH} does not exist."
        return 1
    fi

    # Verify if flavorName is set
    if [ -z "${flavorName}" ]; then
        echo "Error: flavorName is not set."
        return 1
    fi
# Create a backup of the build types file
    BUILD_TYPES_FILE_BACKUP_PATH="${BUILD_TYPES_FILE_PATH}.bak"
    cp "$BUILD_TYPES_FILE_PATH" "$BUILD_TYPES_FILE_BACKUP_PATH"


    # Define the content to be inserted with correct indentation
    INSERT_CONTENT="productFlavors.${flavorName}.signingConfig signingConfigs.releaseSigningConfig"

    # Find the line number for 'release {'
    RELEASE_LINE_NUMBER=$(awk '/release \{/ {print NR; exit}' "${BUILD_TYPES_FILE_PATH}")

    # Check if 'release {' block is found
    if [ -n "${RELEASE_LINE_NUMBER}" ]; then
        # Find the line number for 'shrinkResources true' after 'release {'
        SHRINK_LINE_NUMBER=$(awk "NR>${RELEASE_LINE_NUMBER} && /shrinkResources true/ {print NR; exit}" "${BUILD_TYPES_FILE_PATH}")

        # If 'shrinkResources true' is found, insert after it
        if [ -n "${SHRINK_LINE_NUMBER}" ]; then
            sed -i "$((SHRINK_LINE_NUMBER+1))i${INSERT_CONTENT}" "${BUILD_TYPES_FILE_PATH}"
        else
            # If 'shrinkResources true' not found, insert six lines after 'release {'
            sed -i "$((RELEASE_LINE_NUMBER+6))i${INSERT_CONTENT}" "${BUILD_TYPES_FILE_PATH}"
        fi

        echo "Build type configuration added successfully."
         
    else
        echo "Error: 'release {' block not found in the file."
        # mv "${BUILD_TYPES_FILE_PATH}.bak" "$BUILD_TYPES_FILE_PATH"
            terminate_script_and_rollback
      
        return 1
    fi
}


# Function to generate Flutter Launcher Icons
generate_flutter_launcher_icons() {
       # Check if the project name matches "dynamic_erp"
    if [ "$projectName" == "dynamic_erp" ]; then
        generate_flutter_launcher_icons_erp_mode
        return 0 # Terminate the current function
    fi
    iconFileNamePNG="${flavorName}.png"
    iconFileNameJPG="${flavorName}.jpg"
    iconFileNameJPEG="${flavorName}.jpeg"
    YAML_FILE_NAME="flutter_launcher_icons-${flavorName}.yaml"

    # Check if the expected image in any supported format exists in the specified path
    if [ ! -f "$assetPath$iconFileNamePNG" ] && [ ! -f "$assetPath$iconFileNameJPG" ] && [ ! -f "$assetPath$iconFileNameJPEG" ]; then
        echo "No image file found for '$flavorName' with supported formats (.png, .jpg, .jpeg)."
        read -p "Do you want to upload an image now? (y/n): " uploadChoice
        if [ "$uploadChoice" == "y" ]; then
            # Add logic here to handle image upload
            echo "Please upload an image in one of the supported formats (.png, .jpg, .jpeg) to '$assetPath' and press Enter when done."
            read -p "Press Enter after uploading the image."
            if [ -f "$assetPath$iconFileNamePNG" ] || [ -f "$assetPath$iconFileNameJPG" ] || [ -f "$assetPath$iconFileNameJPEG" ]; then
                echo "Image uploaded successfully."
            else
                echo "Image upload confirmation failed. Aborting."
                rollback_changes
                return 1
            fi
        else
        rollback_changes
            echo "Aborting the image generation process."
            return 1
        fi
    fi

    # Determine the actual image file name to be used
    if [ -f "$assetPath$iconFileNamePNG" ]; then
        actualIconFileName="$iconFileNamePNG"
    elif [ -f "$assetPath$iconFileNameJPG" ]; then
        actualIconFileName="$iconFileNameJPG"
    elif [ -f "$assetPath/$iconFileNameJPEG" ]; then
        actualIconFileName="$iconFileNameJPEG"
    fi
    
    cat > "$YAML_FILE_NAME" <<EOL
flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  image_path: "$assetPath$actualIconFileName"
EOL
     
    flutter pub run flutter_launcher_icons:main -f "$YAML_FILE_NAME"

    if [ $? -eq 0 ]; then
        log_message "flutter_launcher_icons run successfully for $YAML_FILE_NAME"
         rm "$YAML_FILE_NAME"
    else
       flutter pub add flutter_launcher_icons

         rm "$YAML_FILE_NAME"
         flutter pub get
       flutter pub run flutter_launcher_icons:main -f "$YAML_FILE_NAME"
        log_message "ERROR: Failed to run flutter_launcher_icons for $YAML_FILE_NAME."
          terminate_script_and_rollback
        return 1
    fi
}

# Function to generate Flutter Launcher Icons for dynamicerp model
generate_flutter_launcher_icons_erp_mode() {
    assetPath="./assets/launcher_icons"
    iconFileNamePNG="${flavorName}.png"
    iconFileNameJPG="${flavorName}.jpg"
    iconFileNameJPEG="${flavorName}.jpeg"
    YAML_FILE_NAME="flutter_launcher_icons-${flavorName}.yaml"

    # Check if the expected image in any supported format exists in the specified path
    if [ ! -f "$assetPath$iconFileNamePNG" ] && [ ! -f "$assetPath$iconFileNameJPG" ] && [ ! -f "$assetPath$iconFileNameJPEG" ]; then
        echo "No image file found for '$flavorName' with supported formats (.png, .jpg, .jpeg)."
        read -p "Do you want to upload an image now? (y/n): " uploadChoice
        if [ "$uploadChoice" == "y" ]; then
            # Add logic here to handle image upload
            echo "Please upload an image in one of the supported formats (.png, .jpg, .jpeg) to '$assetPath' and press Enter when done."
            read -p "Press Enter after uploading the image."
            if [ -f "$assetPath$iconFileNamePNG" ] || [ -f "$assetPath$iconFileNameJPG" ] || [ -f "$assetPath$iconFileNameJPEG" ]; then
                echo "Image uploaded successfully."
            else
                echo "Image upload confirmation failed. Aborting."
                generate_flutter_launcher_icons
                return 0
            fi
        else
            echo "continuing with default logo"
            return 0
        fi
    fi

    # Determine the actual image file name to be used
    if [ -f "$assetPath$iconFileNamePNG" ]; then
        actualIconFileName="$iconFileNamePNG"
    elif [ -f "$assetPath$iconFileNameJPG" ]; then
        actualIconFileName="$iconFileNameJPG"
    elif [ -f "$assetPath/$iconFileNameJPEG" ]; then
        actualIconFileName="$iconFileNameJPEG"
    fi
    
    cat > "$YAML_FILE_NAME" <<EOL
flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  image_path: "$assetPath$actualIconFileName"
EOL
     
    flutter pub run flutter_launcher_icons:main -f "$YAML_FILE_NAME"

    if [ $? -eq 0 ]; then
        log_message "flutter_launcher_icons run successfully for $YAML_FILE_NAME"
         rm "$YAML_FILE_NAME"
    else
       flutter pub add flutter_launcher_icons
         rm "$YAML_FILE_NAME"
         flutter pub get
       flutter pub run flutter_launcher_icons:main -f "$YAML_FILE_NAME"
        log_message "ERROR: Failed to run flutter_launcher_icons for $YAML_FILE_NAME."
          terminate_script_and_rollback
        return 1
    fi
}


# Call the function to add the new enum value


add_new_flavor() {
    read_user_inputs
    add_env_type_in_dart
    add_flavor_detail_in_gradle
    add_build_type_configuration
    generate_flutter_launcher_icons
    delete_backup_files
}


# Start the script
add_new_flavor
