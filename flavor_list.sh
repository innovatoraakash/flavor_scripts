export LC_ALL=C.UTF-8

dart_file="./lib/config/flavor/flavor_config_data.dart"
flavorList=()

while IFS= read -r line; do
    value=$(echo "$line" | sed 's/\b\(final\|const\|sample\)\b//g')
    if [[ -z "$value" ]]; then
        continue  # Skip if the value is empty after removal
    fi
    if [[ " ${flavorList[@]} " =~ " $value " ]]; then
        echo "Duplicate value found: $value"
        exit 1  # Exit with an error code
    fi
    flavorList+=("$value")
done < <(grep -oP '^  \K\w+' "$dart_file")

echo "Flavor values: ${flavorList[@]}"



