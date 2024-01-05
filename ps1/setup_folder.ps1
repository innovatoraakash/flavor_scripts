function Setup-Flavor {
    Write-Host "Setting up new flavor..."
    & ".\scripts\create_flavor_gradle.sh"
    & ".\scripts\create_buildtype.sh"
    & ".\scripts\download_master_key.sh"
    & ".\scripts\create_signin_config.sh"
    & ".\scripts\add_file_path_to_build_gradle.sh"
    & ".\scripts\create_flavor_config_dart_file.sh"
    & ".\scripts\create_Asset_Folder"

    Write-Host "Flavor setup completed."
}

function Add-Flavor {
    Write-Host "Adding a new flavor..."
    Set-Location -Path "E://flavor_scripts"
    & ".\add_flavor.ps1"
    Write-Host "New flavor added."
}

Write-Host "Please select an option:"
Write-Host "1: Setup a flavor Folders"
Write-Host "2: Add New Flavor"
$user_choice = Read-Host "Enter your choice"

switch ($user_choice) {
    "1" { Setup-Flavor }
    "2" { Add-Flavor }
    default { Write-Host "Invalid input. Please enter '1' for setup or '2' for add." }
}
