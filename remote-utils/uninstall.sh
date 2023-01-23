#!/bin/bash

case "$OSTYPE" in
    solaris*) os="SOLARIS" ;;
    darwin*)	os="MAC" ;;
    linux*)	 os="LINUX" ;;
    bsd*)		 os="BSD" ;;
    msys*)		os="WINDOWS" ;;
    cygwin*)	os="WINDOWS" ;;
    *)				os="unknown: $OSTYPE" ;;
esac

case "$os" in
    "MAC") target="$HOME/.zshrc" ;;
    "LINUX") target="$HOME/.bashrc"
esac

echo "Removing $target lines..."

case "$os" in
    "MAC") sed -i '' -e "/# remote-utils envs - start/,/# remote-utils envs - end/d" ~/.zshrc ;;
    "LINUX") sed -i "/# remote-utils envs - start/,/# remote-utils envs - end/d" ~/.bashrc
esac