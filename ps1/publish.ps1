# Define file paths
$dart_file = ".\lib\config\flavor\flavor_config_data.dart"
$key_credentials_json = "android\config\automate\pc-api-4985841030109568680-940-fb3d7f4ebd8d.json"
$key_credentials_json1 = "android\config\automate\api-6145234015965894785-501180-b8d9d6d4d6b0.json"

function Check-FlavorListEmpty {
    . .\flavor_list.ps1

    if ($flavorList.Count -eq 0) {
        $response = Read-Host "The flavor list is empty. Do you want to create a new flavor? (y/N)"
        if ($response -match "^[Yy]$") {
            .\scripts\add_flavor.ps1
            if ($LASTEXITCODE -eq 0) {
                $continue_choice = Read-Host "New flavor added. Press any key to continue or 'N' to abort"
                if ($continue_choice -match "^[Nn]$") {
                    Write-Host "Script aborted."
                    exit 0
                }
            } else {
                Write-Host "Error in adding flavor. Exiting."
                exit 1
            }
        } else {
            Write-Host "Exiting script."
            exit 0
        }
    } else {
        .\scripts\check_duplicate_flavor.ps1
    }
}

function Get-AllFlavor {
    Check-FlavorListEmpty
    . .\flavor_list.ps1

    if ($flavorList.Count -eq 0) {
        Write-Host "The flavor list is empty. Do you want to add a flavor? (Y/N)"
        $userResponse = Read-Host

        if ($userResponse -match "^[Yy]$") {
            .\scripts\add_flavor.ps1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Add flavor successful. Do you want to continue the script? (Y/N)"
                $continueResponse = Read-Host

                if ($continueResponse -match "^[Yy]$") {
                    Get-AllFlavor
                } else {
                    exit 0
                }
            } else {
                Write-Host "Error running addflavor script. Exiting."
                exit 1
            }
        } else {
            exit 0
        }
    }

    $global:flavors = $flavorList
}

Write-Host "Choose a flavor scenario:"
Write-Host "1. Use all available flavors"
Write-Host "2. Choose Specific flavor"
Write-Host "3. Enter custom flavors (space-separated)"

$choice = Read-Host "Enter your choice (1/2/3)"

switch ($choice) {
    "1" {
        Get-AllFlavor
    }
    "2" {
        Check-FlavorListEmpty
        . .\flavor_list.ps1
        Write-Host "Available flavors:"
        foreach ($i in $flavorList.Keys) {
            Write-Host "$i. $($flavorList[$i])"
        }

        do {
            $flavor_numbers = Read-Host "Enter the numbers corresponding to the flavors you want to use (space-separated)"
            $invalid_input = $false
            $invalid_flavors = @()

            foreach ($num in $flavor_numbers -split ' ') {
                if (-not $num -match "^[0-9]+$" -or [int]$num -lt 0 -or [int]$num -ge $flavorList.Count) {
                    $invalid_flavors += $num
                    $invalid_input = $true
                } else {
                    $flavors += $flavorList[$num]
                }
            }

            if ($invalid_input) {
                Write-Host "Invalid input: $($invalid_flavors -join ', '). Please enter valid numbers corresponding to the flavors."
                $flavors = @()
            } else {
                break
            }
        } while ($true)
    }
    "3" {
        # Similar implementation as above for custom flavors
        # ...
    }
    default {
        Write-Host "Invalid choice. Please enter a valid choice (1/2/3):"
    }
}

Write-Host "Selected Flavors:"
foreach ($flavoritem in $flavors) {
    Write-Host "- $flavoritem"
}

$confirmation = Read-Host "Do you want to continue with these flavors? (y/n)"
if ($confirmation -eq "y") {
    Write-Host "Continuing with selected flavors."
    # Proceed with further steps here
} else {
    Write-Host "Operation cancelled by user."
    exit 0
}

# Define the path to the key credentials JSON file

# Loop through each flavor and build the aab and publish the file
foreach ($flavor in $flavors) {
    flutter build appbundle --flavor=$flavor --release
    # Further logic for publishing the file
}
