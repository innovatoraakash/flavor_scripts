#!/bin/bash
#lib\config\flavor\flavor_config_data.dart
dart_file=$(find . -name "flavor_config.dart")


# Check if the file exists
if [ ! -f "$dart_file" ]; then
  echo "Error: File not found - $dart_file"
  exit 1
fi

# Extract customerCode values and check for duplicates
checkDuplicateCustomerCodes() {
  customer_codes=()

  while IFS= read -r line; do
    if [[ "$line" =~ customerCode:\ ([0-9]+), ]]; then
      customer_code="${BASH_REMATCH[1]}"
      if [[ " ${customer_codes[@]} " =~ " $customer_code " ]]; then
        echo "Duplicate customer code found: $customer_code"
        exit 1  # Exit with an error code
      fi
      customer_codes+=("$customer_code")
    fi
  done < "$dart_file"

#  echo "No duplicate customer codes found."
}

# Main script
checkDuplicateCustomerCodes