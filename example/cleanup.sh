#!/bin/bash

# Delete specified folders
rm -rf android ast ios lib linux macos output test windows

# Parse arguments
TARGET=""
LIBRARY_MODE=false

for arg in "$@"; do
  if [[ "$arg" == "android" ]]; then
    TARGET="android"
  elif [[ "$arg" == "--library" ]]; then
    LIBRARY_MODE=true
  fi
done

if [[ "$TARGET" == "android" ]]; then
  if [[ "$LIBRARY_MODE" == true ]]; then
    mkdir -p android/src
    cp build.example.gradle android/build.gradle
  else
    mkdir -p android/app/src
    cp build.example.gradle android/app/build.gradle
  fi
fi
