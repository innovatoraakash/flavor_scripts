# Define paths
$GRADLE_FILE_PATH = ".\android\config\product_flavors.gradle"
$DART_FILE_PATH = ".\lib\config\flavor\flavor_config_data.dart"
$BUILD_TYPES_FILE_PATH = ".\android\config\build_types.gradle"
$SignInConfig_file_Path = ".\android\config\signing_config.gradle"

$DART_FILE_BACKUP_PATH = "${DART_FILE_PATH}.bak"
$GRADLE_FILE_BACKUP_PATH = "${GRADLE_FILE_PATH}.bak"
$BUILD_TYPES_FILE_BACKUP_PATH = "${BUILD_TYPES_FILE_PATH}.bak"
$SignInConfig_file_BACKUP_Path = "${SignInConfig_file_Path}.bak"
$ANDROID_ICON_PATH = ".\android\app\src\$flavorName"
$IOS_ICON_PATH = ".\ios\Runner\Assets.xcassets\AppIcon-$flavorName.appiconset"
$assetPath = ".\flavor_icon\"

# Function to log messages
function Log-Message {
    Param ([string]$Message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
}

function Trim {
    Param ([string]$Input)
    return $Input.Trim()
}

# Function to rollback changes
function Rollback-Changes {
    Write-Host "Rolling back changes..."

    $filesToRollback = @($DART_FILE_BACKUP_PATH, $GRADLE_FILE_BACKUP_PATH, $BUILD_TYPES_FILE_BACKUP_PATH, $SignInConfig_file_BACKUP_Path)
    foreach ($file in $filesToRollback) {
        if (Test-Path $file) {
            $originalFile = $file -replace "\.bak$", ""
            Move-Item -Path $file -Destination $originalFile -Force
            Write-Host "Reverted changes in $originalFile."
        }
        else {
            Write-Host "Backup file $file does not exist. No reversion possible."
        }
    }

    Delete-Directory $ANDROID_ICON_PATH
    Delete-Directory $IOS_ICON_PATH

    Write-Host "Rollback completed."
}

# Function to terminate script and ask for rollback
function Terminate-Script-And-Rollback {
    $choice = Read-Host "Do you want to rollback changes? (y/n)"
    if ($choice -eq "y") {
        Rollback-Changes
    }
    Write-Host "Terminating the script."
    exit
}

# Function to check for errors and potentially initiate rollback
function Check-Error-And-Rollback {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "An error occurred."
        Terminate-Script-And-Rollback
    }
}

# Function to delete a directory
function Delete-Directory {
    Param ([string]$Path)
    if (Test-Path $Path) {
        Write-Host "Deleting directory: $Path"
        Remove-Item -Path $Path -Recurse -Force
    }
    else {
        Write-Host "Directory not found: $Path"
    }
}

# Function to delete backup files
function Delete-Backup-Files {
    Write-Host "Deleting backup files..."

    $backupFiles = @($DART_FILE_BACKUP_PATH, $GRADLE_FILE_BACKUP_PATH, $BUILD_TYPES_FILE_BACKUP_PATH, $SignInConfig_file_BACKUP_Path)
    foreach ($file in $backupFiles) {
        if (Test-Path $file) {
            Remove-Item -Path $file
            Write-Host "Deleted backup file $file."
        }
        else {
            Write-Host "Backup file $file does not exist. No deletion needed."
        }
    }

    Write-Host "Backup file deletion completed."
}

function Read-User-Inputs {
    # This function collects user inputs for setting up a new software flavor, application name, URL, company code, and company name.

    do {
        $flavorName = Read-Host "Enter new flavor name"
        $flavorName = $flavorName.Trim()
        $flavorName = $flavorName.Substring(0,1).ToLower() + $flavorName.Substring(1)

        if (-not $flavorName) {
            Write-Host "Error: Flavor name is required and cannot be empty."
            continue
        }
        elseif ($flavorName -match "\s") {
            Write-Host "Error: Flavor name should not contain spaces."
            continue
        }
        elseif ($flavorName -match "^[0-9]" -or $flavorName -match "[0-9]$") {
            Write-Host "Error: Flavor name cannot start or end with a number."
            continue
        }

        $dartContent = Get-Content $DART_FILE_PATH
        if ($dartContent -match "$flavorName\(") {
            Write-Host "Flavor '$flavorName' already exists. Choose an action:"
            Write-Host "1. Create New Flavor"
            Write-Host "2. Abort"
            $opt = Read-Host "Select an option (1 or 2)"
            switch ($opt) {
                "1" { continue }
                "2" {
                    Write-Host "Operation aborted by user."
                    exit
                }
                default { Write-Host "Invalid option. Please select a valid action (1 or 2)." }
            }
        }
        else {
            break
        }
    } while ($true)

    do {
        $appName = Read-Host "Enter App Name"
        $appName = $appName.Trim()

        if (-not $appName) {
            Write-Host "Error: Application name is required and cannot be empty."
        }
    } while (-not $appName)

    do {
        $companyName = Read-Host "Enter Company Name"
        if (-not $companyName) {
            Write-Host "Error: Company Name is required and cannot be empty."
        }
    } while (-not $companyName)

    do {
        $companyCode = Read-Host "Enter Company Code"
        $companyCode = $companyCode.Trim()

        if (-not $companyCode -match "^[0-9]+$") {
            Write-Host "Error: Company Code must be a numeric value."
            continue
        }

        if ($dartContent -match "companyCode: $companyCode") {
            Write-Host "Code '$companyCode' already exists for flavor '$flavorName'. Choose an action:"
            Write-Host "1. Enter a New Code"
            Write-Host "2. Exit Script"
            Write-Host "3. Show Match"
            $opt = Read-Host "Select an option"
            switch ($opt) {
                "1" { continue }
                "2" {
                    Write-Host "Operation aborted by user."
                    exit
                }
                "3" {
                    Write-Host "Matching enum details:"
                    $dartContent | Select-String -Pattern "EnvironmentType.*companyCode: $companyCode" -Context 0,1
                    continue
                }
                default { Write-Host "Invalid option. Please select a valid action." }
            }
        }
        else {
            break
        }
    } while ($true)

    $urlName = $null
    do {
        Write-Host "Select URL Extension Type:"
        Write-Host "1. .mydynamicerp.com"
        Write-Host "2. .dynamicerp.online"
        Write-Host "3. .dynamicerp.com"
        Write-Host "4. .dealersathi.com"
        Write-Host "5. Custom"
        $extensionType = Read-Host "Enter your choice (1-5)"
        switch ($extensionType) {
            "1" { $urlName = "https://$flavorName.mydynamicerp.com"; break }
            "2" { $urlName = "https://$flavorName.dynamicerp.online"; break }
            "3" { $urlName = "https://$flavorName.dynamicerp.com"; break }
            "4" { $urlName = "https://$flavorName.dealersathi.com"; break }
            "5" {
                do {
                    $customUrl = Read-Host "Enter Custom URL (without Http:)"
                    if (-not $customUrl) {
                        Write-Host "Error: Custom URL is required and cannot be empty."
                    }
                } while (-not $customUrl)
                $customUrl = $customUrl -replace "^https?://"
                $customUrl = $customUrl -replace "^www\."
                $urlName = "https://$customUrl"
                break
            }
            default { Write-Host "Invalid selection. Please choose a valid extension or 'Custom'." }
        }
    } while (-not $urlName)

    # Output the collected data (for verification)
    Write-Host "Flavor Name: $flavorName"
    Write-Host "App Name: $appName"
    Write-Host "Company Name: $companyName"
    Write-Host "Company Code: $companyCode"
    Write-Host "URL: $urlName"
}

function Add-Env-Type-In-Dart {
    # Check if all required arguments are provided
    if (-not $flavorName -or -not $urlName -or -not $companyCode -or -not $companyName) {
        Write-Host "ERROR: Missing arguments. All arguments must be provided."
        return 1
    }

    # Define the new enum value
    $newEnumValue = @"
$flavorName(
    urlName: '$urlName',
    companyCode: $companyCode,
    companyName: '$companyName',
    appName: '$appName'
),
"@

    # Backup the original Dart file
    Copy-Item -Path $DART_FILE_PATH -Destination "${DART_FILE_PATH}.bak"

    # Check if the enum value already exists
    $dartContent = Get-Content $DART_FILE_PATH
    if ($dartContent -match "$flavorName\(") {
        Write-Host "Enum value '$flavorName' already exists. Choose an option:"
        Write-Host "1. Override"
        Write-Host "2. Abort"
        $opt = Read-Host "Select an option (1 or 2)"
        switch ($opt) {
            "1" {
                # Override the existing enum value
                (Get-Content $DART_FILE_PATH) -replace "$flavorName\(.*\)", $newEnumValue | Set-Content $DART_FILE_PATH
                Write-Host "Enum value '$flavorName' overridden successfully."
                break
            }
            "2" {
                # User chooses to abort: Delete backup and exit
                Write-Host "Operation aborted by user."
                Remove-Item -Path "${DART_FILE_PATH}.bak"
                Write-Host "Deleted backup file ${DART_FILE_PATH}.bak."
                return 0
            }
            default { Write-Host "Invalid option. Please choose 'Override' or 'Abort'." }
        }
    } else {
        # Add the new enum value
        $insertLine = $dartContent | Select-String -Pattern 'enum EnvironmentType {' | Select-Object -First 1 -ExpandProperty LineNumber
        if (-not $insertLine) {
            Write-Host "ERROR: Enum 'EnvironmentType' not found in $DART_FILE_PATH."
            Move-Item -Path "${DART_FILE_PATH}.bak" -Destination "$DART_FILE_PATH" -Force
            return 1
        }

        $dartContent = $dartContent | Select-Object -First ($insertLine - 1)
        $dartContent += $newEnumValue
        $dartContent += (Get-Content $DART_FILE_PATH | Select-Object -Skip $insertLine)
        $dartContent | Set-Content $DART_FILE_PATH

        # Verify if the new enum value was added successfully
        $updatedContent = Get-Content $DART_FILE_PATH
        if ($updatedContent -match "$flavorName\(") {
            Write-Host "New enum value '$flavorName' added successfully to $DART_FILE_PATH"
        } else {
            Write-Host "ERROR: Failed to add the new enum value '$flavorName'. Restoring from backup."
            Move-Item -Path "${DART_FILE_PATH}.bak" -Destination "$DART_FILE_PATH" -Force
            return 1
        }
    }
}


function Add-Flavor-Detail-In-Gradle {
    # Define the new flavor block
    $newFlavorBlock = @"
    $flavorName {
        dimension "version"
        applicationIdSuffix ".$flavorName"
        resValue "string", "app_name", "$appName"
        buildConfigField "String", "APP_BASE_URL", "$urlName"
    }
"@

    # Check if the flavor already exists in the Gradle file
    $gradleContent = Get-Content $GRADLE_FILE_PATH -Raw
    if ($gradleContent -match "$flavorName \{") {
        Write-Host "Flavor '$flavorName' already exists in the Gradle file. Please choose an action:"
        Write-Host "1. Create New Flavor"
        Write-Host "2. Abort Operation"
        $opt = Read-Host "Select an option (1 or 2)"
        switch ($opt) {
            "1" {
                Read-User-Inputs
                Add-Flavor-Detail-In-Gradle
                break
            }
            "2" {
                Write-Host "Operation aborted by user. No changes made."
                return 0
            }
            default {
                Write-Host "Invalid option. Please choose 'Create New Flavor' or 'Abort Operation'."
            }
        }
    } else {
        # Backup the original Gradle file before making changes
        Copy-Item -Path $GRADLE_FILE_PATH -Destination "${GRADLE_FILE_PATH}.bak"

        # Insert the new flavor block into the Gradle file
        $gradleFileLines = Get-Content $GRADLE_FILE_PATH
        $flavorInsertPoint = $gradleFileLines | Select-String -Pattern 'productFlavors \{' -AllMatches | Select-Object -First 1 -ExpandProperty LineNumber

        if ($flavorInsertPoint) {
            $modifiedContent = $gradleFileLines[0..($flavorInsertPoint-1)] + $newFlavorBlock + $gradleFileLines[$flavorInsertPoint..$gradleFileLines.Length]
            $modifiedContent | Set-Content $GRADLE_FILE_PATH

            # Verify if the new flavor was added successfully
            $updatedContent = Get-Content $GRADLE_FILE_PATH -Raw
            if ($updatedContent -match "$flavorName \{") {
                Write-Host "New flavor '$flavorName' successfully added to the Gradle file."
            } else {
                Write-Host "Failed to add new flavor '$flavorName'. Restoring original Gradle file."
                Move-Item -Path "${GRADLE_FILE_PATH}.bak" -Destination "$GRADLE_FILE_PATH" -Force
                Terminate-Script-And-Rollback
            }
        } else {
            Write-Host "Failed to find the insertion point for the new flavor in the Gradle file."
            Move-Item -Path "${GRADLE_FILE_PATH}.bak" -Destination "$GRADLE_FILE_PATH" -Force
            Terminate-Script-And-Rollback
        }
    }
}


function Add-BuildType-Configuration {
    # Verify if BUILD_TYPES_FILE_PATH is set
    if (-not $BUILD_TYPES_FILE_PATH) {
        Write-Host "Error: BUILD_TYPES_FILE_PATH is not set."
        return 1
    }

    # Verify if the file exists
    if (-not (Test-Path $BUILD_TYPES_FILE_PATH)) {
        Write-Host "Error: File $BUILD_TYPES_FILE_PATH does not exist."
        return 1
    }

    # Verify if flavorName is set
    if (-not $flavorName) {
        Write-Host "Error: flavorName is not set."
        return 1
    }

    # Define the content to be inserted
    $INSERT_CONTENT = "productFlavors.$flavorName.signingConfig signingConfigs.releaseSigningConfig"

    try {
        $fileContent = Get-Content $BUILD_TYPES_FILE_PATH -Raw
        # Find the line number for 'release {'
        $releaseLineNumber = Select-String -InputObject $fileContent -Pattern 'release \{' -AllMatches | Select-Object -First 1 -ExpandProperty LineNumber

        # Check if 'release {' block is found
        if ($releaseLineNumber) {
            # Find the line number for 'shrinkResources true' after 'release {'
            $shrinkLineNumber = $fileContent -split "`n" | Select-String -Pattern 'shrinkResources true' -AllMatches | Where-Object { $_.LineNumber -gt $releaseLineNumber } | Select-Object -First 1 -ExpandProperty LineNumber

            # Determine where to insert the new content
            $insertLineNumber = $shrinkLineNumber ? $shrinkLineNumber + 1 : $releaseLineNumber + 6
            $fileContentArray = $fileContent -split "`n"
            $fileContentArray = $fileContentArray[0..($insertLineNumber-1)] + $INSERT_CONTENT + $fileContentArray[$insertLineNumber..$fileContentArray.Length]

            # Update the file
            $fileContentArray -join "`n" | Set-Content $BUILD_TYPES_FILE_PATH
            Write-Host "Build type configuration added successfully."
        }
        else {
            Write-Host "Error: 'release {' block not found in the file."
            return 1
        }
    }
    catch {
        Write-Host "An error occurred: $_"
        # Consider calling terminate_script_and_rollback here if needed
        return 1
    }
}

function Generate-Flutter-Launcher-Icons {
    $iconFileNamePNG = "${flavorName}.png"
    $iconFileNameJPG = "${flavorName}.jpg"
    $iconFileNameJPEG = "${flavorName}.jpeg"
    $YAML_FILE_NAME = "flutter_launcher_icons-${flavorName}.yaml"

    if (-not (Test-Path "$assetPath$iconFileNamePNG") -and -not (Test-Path "$assetPath$iconFileNameJPG") -and -not (Test-Path "$assetPath$iconFileNameJPEG")) {
        Write-Host "No image file found for '$flavorName' with supported formats (.png, .jpg, .jpeg)."
        $uploadChoice = Read-Host "Do you want to upload an image now? (y/n)"
        if ($uploadChoice -eq "y") {
            Write-Host "Please upload an image in one of the supported formats (.png, .jpg, .jpeg) to '$assetPath' and press Enter when done."
            Read-Host "Press Enter after uploading the image."
            if (Test-Path "$assetPath$iconFileNamePNG" -or Test-Path "$assetPath$iconFileNameJPG" -or Test-Path "$assetPath$iconFileNameJPEG") {
                Write-Host "Image uploaded successfully."
            } else {
                Write-Host "Image upload confirmation failed. Aborting."
                Terminate-Script-And-Rollback
                return 1
            }
        } else {
            Terminate-Script-And-Rollback
            Write-Host "Aborting the image generation process."
            return 1
        }
    }

    # Determine the actual image file name to be used
    $actualIconFileName = if (Test-Path "$assetPath$iconFileNamePNG") { $iconFileNamePNG }
    elseif (Test-Path "$assetPath$iconFileNameJPG") { $iconFileNameJPG }
    elseif (Test-Path "$assetPath$iconFileNameJPEG") { $iconFileNameJPEG }

    $yamlContent = @"
flutter_launcher_icons:
  android: true
  ios: true
  remove_alpha_ios: true
  image_path: "$assetPath$actualIconFileName"
"@

    $yamlContent | Set-Content $YAML_FILE_NAME

    try {
        flutter pub run flutter_launcher_icons:main -f $YAML_FILE_NAME
        if ($LASTEXITCODE -eq 0) {
            Log-Message "flutter_launcher_icons run successfully for $YAML_FILE_NAME"
            Remove-Item $YAML_FILE_NAME
        } else {
            flutter pub add flutter_launcher_icons
            Remove-Item $YAML_FILE_NAME
            flutter pub get
            flutter pub run flutter_launcher_icons:main -f $YAML_FILE_NAME
            Log-Message "ERROR: Failed to run flutter_launcher_icons for $YAML_FILE_NAME."
            Terminate-Script-And-Rollback
            return 1
        }
    }
    catch {
        Write-Host "An error occurred: $_"
        Terminate-Script-And-Rollback
        return 1
    }
}
# Call the function to add the new enum value

function Add-New-Flavor {
    Read-User-Inputs
    Add-Env-Type-In-Dart
    Add-Flavor-Detail-In-Gradle
    Add-BuildType-Configuration
    Generate-Flutter-Launcher-Icons
    Delete-Backup-Files
}

# Start the script
Add-New-Flavor
