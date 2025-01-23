#!/bin/bash

#takes <dir> <wordToSearchFor> <wordToReplaceWith> and replaces all instances in all files in the dir
# e.g. folderStreamEdit . this that

dir=$1
srchFor=$2
replWith=$3

# Check if the required arguments are provided
if [ $# -lt 3 ]; then
    echo "Error: Insufficient arguments."
    echo "Usage: $0 <directory> <search_pattern> <replacement_text>"
    exit 1
fi

# Assign the directory path from the argument
directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist."
    exit 1
fi

# Loop through each file in the directory
if [ -d "$directory" ]; then
    # For each file in this directory
    for file in "$directory"/*
    do
        if [ "$file" = "$0" ] || [ -d "$file" ]; then
            echo "Skip editing the script! + $file"
        else
            if [ -f "$file" ]; then
                sed -i "s|$srchFor|$replWith|g" "$file"
               #echo "Edited file: $file"
            else
                echo "Skipping non-regular file: $file"
            fi
        fi
    done
else
    echo "The specified directory does not exist: $directory"
fi