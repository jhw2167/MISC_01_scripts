#!/bin/bash

# Takes <dir> <wordToSearchFor> <wordToReplaceWith> and replaces all instances in all files in the dir and subdirs
# e.g. folderStreamEdit.sh . this that

dir=$1
srchFor=$2
replWith=$3

# Check if the required arguments are provided
if [ $# -lt 3 ]; then
    echo "Error: Insufficient arguments."
    echo "Usage: $0 <directory> <search_pattern> <replacement_text>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

# Recursively loop through all files in the directory and its subdirectories
find "$dir" -type f | while read -r file; do
    if [ "$file" = "$0" ]; then
        echo "Skipping the script itself: $file"
    else
        sed -i "s|$srchFor|$replWith|g" "$file"
        echo "Edited file: $file"
    fi
done
