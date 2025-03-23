#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Provide file as argument"
    exit 1
fi

FILE_TO_TRANSFER="$1"
dos2unix "$FILE_TO_TRANSFER"

./moveData.sh "$FILE_TO_TRANSFER"