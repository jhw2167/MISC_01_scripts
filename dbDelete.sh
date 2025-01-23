#!/bin/bash

# Pulls up the latest logfile in the specified folder, forks, and opens it in its own notepad window.
# Usage: ./dbDelete folder

dir=$1

# Check if directory argument is provided
if [ -z "$dir" ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

# Construct the path to the latest log file
log_file="${dir}/run/logs/latest.log"

# Check if the log file exists
if [ ! -f "$log_file" ]; then
    echo "Log file does not exist: $log_file"
    exit 1
fi

# Open the log file in notepad
notepad "$log_file" &
