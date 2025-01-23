#!/bin/bash

if [ $# -eq 0 ]; then
    exit 1
fi

./folderStreamEdit.sh "BO1-Reimagined-$1/maps" "iprintln" "//iprintln"
./folderStreamEdit.sh "BO1-Reimagined-$1/maps" "////iprintln" "//iprintln"

./folderStreamEdit.sh "BO1-Reimagined-$1/clientscripts" "iprintln" "//iprintln"
./folderStreamEdit.sh "BO1-Reimagined-$1/clientscripts" "////iprintln" "//iprintln"

./folderStreamEdit.sh "BO1-Reimagined-$1/maps" "REMOVE_DEV_OVERRIDES//\*/\\*" " "
./folderStreamEdit.sh "BO1-Reimagined-$1/maps" "dev_only = true;" "dev_only = false;"
