#!/bin/bash
# Get the full path of the current script
SCRIPT_PATH=$(realpath "$0")

# Extract the directory from the full path
BASE_DIR=$(dirname "$SCRIPT_PATH")
# Define file paths

dart_file=$(find . -name "flavor_config.dart")
key_credentials_json="android/config/automate/pc-api-4985841030109568680-940-fb3d7f4ebd8d.json"
key_credentials_json1="android/config/automate/api-6145234015965894785-501180-b8d9d6d4d6b0.json"
build_gradle_path="android/app/build.gradle"
if [ -z "$dart_file" ]; then
    # File not found
    echo -e "${RED}flavor_config.dart not found.\nPlease rename your file containing EnvironmentType to flavor_config.dart, or run flavor setup.${NC}"
    exit
fi


# Define the content of the Gemfile
gemfile_content='source "https://rubygems.org"\n\ngem "fastlane"'

# Specify the path to the Gemfile
gemfile_path="./android/Gemfile"

# Create the Gemfile with the specified content
echo -e "$gemfile_content" > "$gemfile_path"

# Output success message
echo "Gemfile created successfully at $gemfile_path"

# Use grep to find the line containing 'applicationId' and awk to extract the suffix
applicationId=$(grep "applicationId" "$build_gradle_path" | awk -F '"' '{print $2}')

# Print the extracted suffix
echo "app id: $applicationId"
# Define color codes
YELLOW='\033[1;33m' # Yellow color
RED='\033[0;31m'    # Red color
GREEN='\033[0;32m'  # Green color
NC='\033[0m'        # No color

checkFlavorListEmpty() {
    source "${BASE_DIR}/flavor_list.sh"

    if [ ${#flavorList[@]} -eq 0 ]; then
        read -p "$The flavor list is empty. Do you want to create a new flavor? (y/N): " response
        if [[ $response =~ ^[Yy]$ ]]; then
            "${BASE_DIR}/scripts/add_flavor.sh"
            if [ $? -eq 0 ]; then
                read -p "$New flavor added. Press any key to continue or 'N' to abort: " continue_choice
                if [[ $continue_choice =~ ^[Nn]$ ]]; then
                    echo -e "$Script aborted."
                    exit 0
                fi
            else
                echo -e "$Error in adding flavor. Exiting."
                exit 1
            fi
        else
            echo -e "${GREEN}Exiting script."
            exit 0
        fi
    else
        "${BASE_DIR}/scripts/check_duplicate_flavor.sh"
    fi
}

getAllflavor() {
    # checkFlavorListEmpty
    source "${BASE_DIR}/flavor_list.sh"

    if [ ${#flavorList[@]} -eq 0 ]; then
        echo -e "$The flavor list is empty. Do you want to add a flavor? (Y/N)"
        read userResponse

        if [[ "$userResponse" == "Y" || "$userResponse" == "y" ]]; then
            "${BASE_DIR}/scripts/add_flavor.sh"
            if [ $? -eq 0 ]; then
                echo -e "$Add flavor successful. Do you want to continue the script? (Y/N)"
                read continueResponse

                if [[ "$continueResponse" == "Y" || "$continueResponse" == "y" ]]; then
                    getAllFlavor
                else
                    exit 0
                fi
            else
                echo -e "$Error running addflavor script. Exiting."
                exit 1
            fi
        else
            exit 0
        fi
    fi

    flavors="${flavorList[@]}"
}

echo -e "${GREEN}Choose a flavor scenario:"
echo "1. Use all available flavors"
echo "2. Choose Specific flavor"
echo "3. Enter custom flavors (space-separated)"

read -p "Enter your choice (1/2/3): " choice

case $choice in
  1)
    getAllflavor
    ;;
  2)
    #   checkFlavorListEmpty
  source "${BASE_DIR}/flavor_list.sh"


  while true; do
    read -p " Enter the numbers corresponding to the flavors you want to use (space-separated): " flavor_numbers
    invalid_input=false
    invalid_flavors=()

    for num in $flavor_numbers; do
      if [[ ! "$num" =~ ^[0-9]+$ ]] || ((num < 0)) || ((num >= ${#flavorList[@]})); then
        invalid_flavors+=("$num")
        invalid_input=true
      else
        flavors+=("${flavorList[$num]}")
      fi
    done

    if [ "$invalid_input" = true ]; then
      echo -e "$Invalid input: ${invalid_flavors[*]}. Please enter valid numbers corresponding to the flavors."
      flavors=()
    else
      break
    fi
  done
  ;;
  3)
    # checkFlavorListEmpty
    source "${BASE_DIR}/flavor_list.sh"
  

    read -p "$Enter Flavor Name (space-separated): " custom_flavors_input
    IFS=' ' read -ra custom_flavors <<< "$custom_flavors_input"
    invalid_flavors=()

    for cf in "${custom_flavors[@]}"; do
        if [[ " ${flavorList[@]} " =~ " ${cf} " ]]; then
            flavors+=("$cf")
        else
            invalid_flavors+=("$cf")
        fi
    done

    while [ ${#invalid_flavors[@]} -gt 0 ]; do
        echo -e "$The following flavors are not available: ${invalid_flavors[*]}"
        echo -e "$Do you want to:"
        echo "1. Replace Invalid Flavors"
        echo "2. Choose All Flavors"
        echo "3. Choose Specific flavor"
        echo "4. Abort"
        read -p "Enter your choice (1/2/3/4): " choice

        case $choice in
           1)
for inv_flavor in "${invalid_flavors[@]}"; do
    echo "Please enter a replacement for '$inv_flavor':"
    read -r replacement

    # Check if the replacement flavor is valid
    if [[ " ${flavorList[*]} " =~ " ${replacement} " ]]; then
        # Check if the replacement flavor already exists in the 'flavors' array
        if [[ " ${flavors[*]} " =~ " ${replacement} " ]]; then
            # The replacement flavor already exists, just remove the invalid flavor
            echo "'$replacement' already exists in the flavors. Removing '$inv_flavor'."
        else
            # The replacement flavor is new, add it to the 'flavors' array
            flavors+=("$replacement")
        fi

        # Replace or remove the invalid flavor in 'flavors' array
        for i in "${!flavors[@]}"; do
            if [ "${flavors[i]}" = "$inv_flavor" ]; then
                flavors[i]=$replacement
                break # Exit the loop after replacing
            fi
        done

        # Remove the invalid flavor from 'invalid_flavors' array
        for i in "${!invalid_flavors[@]}"; do
            if [ "${invalid_flavors[i]}" = "$inv_flavor" ]; then
                unset 'invalid_flavors[i]'
                # Re-index the 'invalid_flavors' array to account for the unset element
                invalid_flavors=("${invalid_flavors[@]}")
                break # Exit the loop after removing
            fi
        done
    else
        echo "Invalid replacement flavor."
    fi
done

# Print the updated flavors list
echo "Updated flavors:"
for flavoritem in "${flavors[@]}"; do
    echo "- $flavoritem"
done
;;
            2)
                getAllFlavor;;
            3)
                source ./flavor_list.sh
                

                read -p "$Enter the numbers corresponding to the flavors you want to use (space-separated): " flavor_numbers

                for num in $flavor_numbers; do
                  if [[ ! "$num" =~ ^[0-9]+$ ]] || ((num < 0)) || ((num >= ${#flavorList[@]})); then
                    echo -e "$Invalid flavor number $num. Exiting."
                    exit 1
                  fi
                  flavors+=("${flavorList[$num]}")
                done
                ;;
            4)
                echo -e "$Operation aborted."
                exit 1
                ;;
           *)
        echo -e "$Invalid choice. Please enter a valid choice (1/2/3/4):"
                ;;
        esac
    done
    ;;
    *)
        echo -e "$Invalid choice. Please enter a valid choice (1/2/3):"
esac

echo -e "${GREEN}Selected Flavors:"
for flavoritem in "${flavors[@]}"; do
  echo "- $flavoritem"
done

read -p "$Do you want to continue with these flavors? (y/n): " confirmation
if [[ $confirmation == "y" ]]; then
  echo -e "${GREEN}Continuing with selected flavors."
  # Proceed with further steps here
else
  echo -e "$Operation cancelled by user."
  exit 0
fi


# Define the path to the key credentials JSON file
# cd android
# Loop through each flavor and build the aab and publish the file
for flavor in "${flavors[@]}"
do  
# Build the Android App Bundle for the flavor
 flutter build appbundle --flavor $flavor --release


 # Publish the APK to the Play Store using the key credentials JSON
  AAB_PATH="./build/app/outputs/bundle/${flavor}Release/app-$flavor-release.aab"

  #fastlane uses ruby
  #install ruby for windows 
  #gem install fastlane
  #fastlane init
  while true; do
  #checks for the infodynamic1 account and no republish case 
  #
    if fastlane supply --aab "$AAB_PATH" --track "production" --json_key "$key_credentials_json" --package_name "$applicationId.$flavor"; then
        echo "success"
        break
    #checks for the infodynamic1 account and republish case 
    elif fastlane supply --aab "$AAB_PATH" --track "production" --json_key "$key_credentials_json" --package_name "$applicationId.re.$flavor"; then
        echo "success after package name change"
        break

    #checks for infodynamic
    elif fastlane supply --aab "$AAB_PATH" --track "production" --json_key "$key_credentials_json1" --package_name "$applicationId.$flavor"; then
        echo "success after json file change"
        break
    elif fastlane supply --aab "$AAB_PATH" --track "production" --json_key "$key_credentials_json1" --package_name "$applicationId.re.$flavor"; then
        echo "success after pkg and json change"
        break
    else
        echo "no appid match at playstore"

        break
    fi
  done
done