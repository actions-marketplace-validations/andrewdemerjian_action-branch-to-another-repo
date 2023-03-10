#!/bin/bash
# Target directory
TARGET=$3
echo "Finding and copying files and folders to $TARGET"
for i in $(git diff --name-only $1 $2)
  do
    # First create the target directory, if it doesn't exist.
    mkdir -p "$TARGET/$(dirname $i)"
    # Then copy over the file.
    cp "$i" "$TARGET/$i"
  done
echo "Files copied to target directory";
