#!/bin/bash
#lib\config\flavor\flavor_config.dart
dart_file=$(find . -name "flavor_config.dart")


# Check if the file exists
if [ ! -f "$dart_file" ]; then
  echo "Error: File not found - $dart_file"
  exit 1
fi

# Extract Company Code values and check for duplicates
checkDuplicateCompanyCodes() {
  company_codes=()

  while IFS= read -r line; do
    if [[ "$line" =~ companyCode:\ ([0-9]+), ]]; then
      company_code="${BASH_REMATCH[1]}"
      if [[ " ${company_codes[@]} " =~ " $company_code " ]]; then
        echo "Duplicate companyCoder code found: $company_code"
        exit 1  # Exit with an error code
      fi
      company_codes+=("$company_code")
    fi
  done < "$dart_file"

#  echo "No duplicate Company codes found."
}

# Main script
checkDuplicateCompanyCodes