#!/bin/bash
# Get the full path of the current script
SCRIPT_PATH=$(realpath "$0")

# Extract the directory from the full path
BASE_DIR=$(dirname "$SCRIPT_PATH")
# Define file paths

dart_file=$(find . -name "flavor_config.dart")
key_credentials_json="android/config/automate/pc-api-4985841030109568680-940-fb3d7f4ebd8d.json"
key_credentials_json1="android/config/automate/api-6145234015965894785-501180-b8d9d6d4d6b0.json"
if [ -z "$dart_file" ]; then
    # File not found
    echo -e "${RED}flavor_config.dart not found.\nPlease rename your file containing EnvironmentType to flavor_config.dart, or run flavor setup.${NC}"
    exit
fi
# Define color codes
YELLOW='\033[1;33m' # Yellow color
RED='\033[0;31m'    # Red color
GREEN='\033[0;32m'  # Green color
NC='\033[0m'        # No color



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

    if [ ${#invalid_flavors[@]} -gt 0 ]; then
        echo -e "$The following flavors are not available: ${invalid_flavors[*]}"        
                echo -e "$Operation aborted."
                exit 1
    fi  
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

# Loop through each flavor and build the aab and publish the file
for flavor in "${flavors[@]}"
do  
# Build the Android App Bundle for the flavor
 flutter build apk --release --flavor $flavor

  done
# done