#!/bin/bash

# Script: recursiveStreamEdit.sh
# Usage: recursiveStreamEdit.sh <parentDir> <wordToSearchFor> <wordToReplaceWith>
# Example: recursiveStreamEdit.sh . this that

parentDir=$1
srchFor=$2
replWith=$3

if [ -z "$parentDir" ] || [ -z "$srchFor" ] || [ -z "$replWith" ]; then
    echo "Usage: $0 <parentDir> <wordToSearchFor> <wordToReplaceWith>"
    exit 1
fi

if [ ! -d "$parentDir" ]; then
    echo "Error: $parentDir is not a directory."
    exit 1
fi

# For each directory in the parent directory
for dir in "$parentDir"/*/; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        ./folderStreamEdit.sh "$dir" "$srchFor" "$replWith"
    fi
done
