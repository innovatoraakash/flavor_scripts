export LC_ALL=C.UTF-8

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# dart_file="./lib/config/flavor/flavor_config_data.dart"
dart_file=$(find . -name "flavor_config.dart")
# Check if the file was found
if [ -z "$dart_file" ]; then
    # File not found
    echo -e "${RED}flavor_config.dart not found.\nPlease rename your file containing EnvironmentType to flavor_config.dart, or run flavor setup.${NC}"
    exit
else
    # File found
    echo -e "${GREEN}flavor_config.dart found at: $dart_file${NC}"
fi

flavorList=()

while IFS= read -r line; do
    value=$(echo "$line" | sed 's/\b\(final\|const\|static\|import\|print\|log\|sample\)\b//g')
    if [[ -z "$value" ]]; then
        continue  # Skip if the value is empty after removal
    fi
    if [[ " ${flavorList[@]} " =~ " $value " ]]; then
        echo "Duplicate value found: $value"
        exit 1  # Exit with an error code
    fi
    flavorList+=("$value")
done < <(grep -oP '^  \K\w+' "$dart_file")

echo -e "${YELLOW}Flavor values:${NC}"

for i in "${!flavorList[@]}"; do
  echo -e "$i.${GREEN} ${flavorList[$i]}${NC}"

done



