$dart_file = "./lib/config/flavor/flavor_config_data.dart"
$flavorList = @()

# Read each line of the file
Get-Content $dart_file | ForEach-Object {
    # Extract words that are not 'final', 'const', or 'sample' using regex
    $matches = [Regex]::Matches($_, '^\s\s(\w+)')
    foreach ($match in $matches) {
        $value = $match.Groups[1].Value -replace '(final|const|sample)', ''
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue # Skip if the value is empty after removal
        }
        if ($flavorList -contains $value) {
            Write-Host "Duplicate value found: $value"
            exit 1 # Exit with an error code
        }
        $flavorList += $value
    }
}

# Output the flavor values
Write-Host "Flavor values: $($flavorList -join ', ')"


