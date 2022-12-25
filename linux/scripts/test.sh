#!/bin/bash

echo "Testing!"
echO ""

echo "Path is: $PATH"
echo "PWD is: $PWD"
echo ""

# Determine OS
echo "OS: $OSTYPE"
echo ""

echo "System info: $(uname -a)"
echo ""

if ! [ -x "$(command -v docker)" ]; then
    echo "Docker is not installed."
else
    echo "Docker is installed."
fi
echo ""

echo "Done!"