#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Root directory
ROOT_DIR=$(pwd)

# Read properties from gradle.properties
GROUP=$(grep -E "^group=" "$ROOT_DIR/gradle.properties" | cut -d'=' -f2 | tr -d '[:space:]')
MOD_ID=$(grep -E "^mod_id=" "$ROOT_DIR/gradle.properties" | cut -d'=' -f2 | tr -d '[:space:]')

# Validate the required properties are set
if [[ -z "$GROUP" || -z "$MOD_ID" ]]; then
    echo "Error: 'group' or 'mod_id' property is missing in gradle.properties"
    exit 1
fi

# Convert the group property to directory path (e.g., com.example to com/example)
GROUP_DIR=$(echo "$GROUP" | tr '.' '/')

# Directories to process
SUBPROJECTS=("forge/src/main/java" "common/src/main/java" "fabric/src/main/java")

# Process each subproject
for SUBPROJECT in "${SUBPROJECTS[@]}"; do
    SRC_DIR="$ROOT_DIR/$SUBPROJECT/com/holybuckets/foundation"
    DEST_DIR="$ROOT_DIR/$SUBPROJECT/$GROUP_DIR"

    # Create new directory structure
    mkdir -p "$DEST_DIR"

    # Move files to new group structure
    if [[ -d "$SRC_DIR" ]]; then
        mv "$SRC_DIR"/* "$DEST_DIR/"
        rm -rf "$SRC_DIR"
        echo "Moved files from $SRC_DIR to $DEST_DIR"
    else
        echo "Directory $SRC_DIR does not exist. Skipping."
    fi
done

# Copy the mixins_template.json file to each subproject
RESOURCES_DIRS=("forge/src/main/resources" "common/src/main/resources" "fabric/src/main/resources")
for RESOURCES_DIR in "${RESOURCES_DIRS[@]}"; do
    if [[ $RESOURCES_DIR == *"forge"* ]]; then
        MIXINS_FILE="$RESOURCES_DIR/${MOD_ID}.forge.mixins.json"
    elif [[ $RESOURCES_DIR == *"fabric"* ]]; then
        MIXINS_FILE="$RESOURCES_DIR/${MOD_ID}.fabric.mixins.json"
    else
        MIXINS_FILE="$RESOURCES_DIR/${MOD_ID}.mixins.json"
    fi

    mkdir -p "$ROOT_DIR/$RESOURCES_DIR"
    cp "$ROOT_DIR/mixins_template.json" "$ROOT_DIR/$MIXINS_FILE"
    echo "Copied mixins_template.json to $MIXINS_FILE"
done

./folderStreamEdit.sh . "com.holybuckets.foundation" "$GROUP"

echo "Initialization complete!"
