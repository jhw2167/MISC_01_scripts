#!/bin/bash

# Deletes the "run" folders for both forge and fabric
# Usage: ./removeRunFolder folder

dir=$1

# Check if directory argument is provided
if [ -z "$dir" ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

# Construct the paths to the run folders
forge_run="${dir}/forge/run"
fabric_run="${dir}/fabric/run"

# Check if the Forge run folder exists and remove it
if [ -d "$forge_run" ]; then
    echo "Removing Forge run folder: $forge_run"
    rm -rf "$forge_run"
else
    echo "Forge run folder does not exist: $forge_run"
fi

# Check if the Fabric run folder exists and remove it
if [ -d "$fabric_run" ]; then
    echo "Removing Fabric run folder: $fabric_run"
    rm -rf "$fabric_run"
else
    echo "Fabric run folder does not exist: $fabric_run"
fi
