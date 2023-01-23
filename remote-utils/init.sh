#!/bin/bash
FOLDER_ROOT=$(dirname $(dirname $(readlink -f "$0")))

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

echo '' >> $target
echo '# remote-utils envs - start' >> $target
echo 'export REMOTE_UTILS_DIR='$FOLDER_ROOT >> $target
echo 'export PATH=$PATH:'$FOLDER_ROOT'/remote-utils/bin' >> $target
echo '# remote-utils envs - end' >> $target
echo '' >> $target
source $target

echo "Echoing vars for test..."
echo "REMOTE_UTILS_DIR=$SMART_HOME_DIR"
echo "PATH=$PATH"

echo "Copying .env.example to .env"
cp $FOLDER_ROOT/.env.example $FOLDER_ROOT/.env

echo "Done!"