#!/bin/bash

# Check if at least 4 arguments are provided
if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <project_name> <version_key> <version_number> [directories]"
    exit 1
fi

# Assign inputs to variables
project_name=$1
version_key=$2
version_number=$3
repo=$4
directories_raw=$5

# Remove square brackets from the directories input and split into an array
directories=()
IFS=' ' read -r -a directories <<< "${directories_raw//[\[\]]/}"

# Print the inputs for debugging
echo "Project Name: $project_name"
echo "Version Key: $version_key"
echo "Version Number: $version_number"
echo "Repo: $repo"
echo "Directories:"
for dir in "${directories[@]}"; do
    echo "  - $dir"
done


NEW_VERSION="$version_number"-SNAPSHOT

#Update in baseDir

# Change directory to MAIN project
echo "Changinge to: $project_name"
cd "${project_name}"

# Update version in main project
sed -i "s/^mod_version=.*/mod_version=$NEW_VERSION/" "gradle.properties"

# impromptu clean of existing repo
maven_repo="C:\Users\jack\.m2\repository\\${repo}"
echo "removing ${maven_repo}"
rm -rf "$maven_repo"

# push project to maven local
./gradlew publishToMavenLocal

# return to parent
cd ..

# Iterate through the predefined directories and update the ${version_key}
for TARGET_DIR in "${directories[@]}"; do

echo "Reading Directory: ${TARGET_DIR}"
    GRADLE_PROPERTIES="$TARGET_DIR/gradle.properties"

    # Check if gradle.properties file exists
    if [ -f "$GRADLE_PROPERTIES" ]; then
        if grep -q "^${version_key}=" "$GRADLE_PROPERTIES"; then
            # Update the existing ${version_key}
            sed -i "s/^${version_key}=.*/${version_key}=$NEW_VERSION/" "$GRADLE_PROPERTIES"
            echo "Updated ${version_key} to '$NEW_VERSION' in '$GRADLE_PROPERTIES'."
        fi
    else
        echo "Warning: gradle.properties file not found in '$TARGET_DIR'. Skipping."
    fi
done
