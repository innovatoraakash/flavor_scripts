#!/bin/bash

# Path to your pubspec.yaml
PUBSPEC="./pubspec.yaml"

# Get the current version from pubspec.yaml
current_version=$(awk '/^version:/{print $2}' "$PUBSPEC")

# Extract the numeric part of the version (assuming it's in the format X.Y.Z+N)
numeric_version=$(echo "$current_version" | cut -d '+' -f 1)

# Extract the build number part of the version
build_number=$(echo "$current_version" | cut -d '+' -f 2)

# Extract the major, minor, and patch versions
major=$(echo "$numeric_version" | cut -d '.' -f 1)
minor=$(echo "$numeric_version" | cut -d '.' -f 2)
patch=$(echo "$numeric_version" | cut -d '.' -f 3)

# Increment the patch version
((patch++))

# Increment the build number
((build_number++))

# Create the new version string
new_version="$major.$minor.$patch+$build_number"

# Replace the version in pubspec.yaml
sed -i "s/^version: .*/version: $new_version/" "$PUBSPEC"

echo "Version updated to $new_version"
