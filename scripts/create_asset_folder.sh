#!/bin/bash

assetPath="flavor_icon"

create_Asset_Folder() {

    # Check if the directory exists
    if [ ! -d "$assetPath" ]; then
        echo "The directory '$assetPath' does not exist."

        select opt in "Create Folder" "Exit App"; do
            case $opt in
                "Create Folder")
                    echo "Creating folder: $assetPath"
                    mkdir -p "$assetPath"
                    if [ -d "$assetPath" ]; then
                        echo "Folder created successfully."

                        # Set full read, write, and execute permissions for all users
                        chmod 777 "$assetPath"
                        echo "Full access permissions set for Flavor asset folder $assetPath"
                    else
                        echo "Failed to create folder."
                        exit 1
                    fi
                    break
                    ;;
                "Exit App")
                    echo "Exiting the application."
                    exit 0
                    ;;
                *)
                    echo "Invalid option. Please choose 'Create Folder' or 'Exit App'."
                    ;;
            esac
        done
    else
        # If the directory already exists, set full permissions
        chmod 777 "$assetPath"
        echo "Full access permissions set for the existing flavor asset folder."
        echo "flavor asset path is  $assetPath ."
    fi
}

create_Asset_Folder