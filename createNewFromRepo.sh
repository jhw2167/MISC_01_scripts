#!/bin/bash

# Ensure the script stops on any error
set -e

# Check if the required argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <github-repo-url>"
    exit 1
fi

# Get the GitHub repository URL from the first argument
REPO_URL="$1"

# Extract the repository name from the URL
REPO_NAME=$(basename -s .git "$REPO_URL")

# Clone the repository locally
echo "Cloning repository $REPO_URL..."
git clone "$REPO_URL"

# Ensure the repository was cloned successfully
if [ ! -d "$REPO_NAME" ]; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# Define the source directory (adjust path if necessary)
SOURCE_DIR="MCM_-_Multi-Loader-Template"

# Ensure the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Copy all files and directories, excluding any directories starting with "."
echo "Copying files from $SOURCE_DIR to $REPO_NAME..."
cd "$SOURCE_DIR"
for item in *; do
    # Skip hidden directories (those starting with ".")
    if [ -d "$item" ] && [[ "$item" == .* ]]; then
        continue
    fi
    # Copy files and directories to the cloned repo
    cp -r "$item" "../$REPO_NAME/"
done

# copy .gitignore over
cp .gitignore "../$REPO_NAME/"

# Change to the cloned repository directory
cd "../$REPO_NAME"

notepad gradle.properties

./init.sh

echo "Files copied successfully."
