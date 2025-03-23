#!/bin/bash

# Loop through each subdirectory in the current directory
for dir in */; do
    # Skip if no directories are found
    [ -d "$dir" ] || continue

    echo "Processing: $dir"

    # Move all contents (files & folders) to the parent directory
    mv "$dir"* .

    # Remove the now empty folder
    rmdir "$dir"

    echo "Moved contents and removed: $dir"
done

echo "All folders flattened!"
