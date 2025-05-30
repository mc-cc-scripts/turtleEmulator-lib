#!/bin/bash

# ---- Whats happening ---- #

# This fetches the dependencies listed in the "libs" variable and saves them in the targetFolder



set -e

libs=(
    "helperFunctions-lib"
    "eventCallStack-lib"
    "ccClass-lib"
    "testSuite-lib"
)

# Basic setup variables
repo="mc-cc-scripts"
branch="master"
targetFolderName=libs


# fetch files.txt and save each file into the targetFolder
fetch() {

    files_txt=$(curl -fsSL "https://raw.githubusercontent.com/$repo/$1/$branch/files.txt")
    if [ -z "$files_txt" ]; then
        echo "Could not load files.txt for $1"
        exit 1
    fi
    while IFS= read -r FILE; do
        rm -f $targetFolderName/$1.lua # rm existing file
        curl -s "https://raw.githubusercontent.com/$repo/$1/$branch/$FILE" -o "$targetFolderName/$FILE"
    done < <(echo  "$files_txt")
}

mkdir -p $targetFolderName

for i in "${libs[@]}"; do
    fetch "$i"
done