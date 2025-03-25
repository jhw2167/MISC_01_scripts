#!/bin/bash

# Exit if any command fails
set -e

# Check arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <source_folder> <destination_folder>"
  exit 1
fi

SRC="$1"
DST="$2"

# Ensure destination folder exists
mkdir -p "$DST"

# Move all .jar files from source to destination (recursive)
find "$SRC" -type f -name "*.jar" | while read -r file; do
  base=$(basename "$file")
  dest="$DST/$base"
  i=1
  while [[ -e "$dest" ]]; do
    dest="$DST/${base%.jar}_$i.jar"
    ((i++))
  done
  echo "Moving: $file -> $dest"
  mv "$file" "$dest"
done

echo "Done."
