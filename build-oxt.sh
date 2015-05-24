#!/bin/bash
# build.sh -- builds OXT files for Libreofffice extensions
#   by Joan Montané, based on code to XPI builind from  Nickolay Ponomarev <asqueella@gmail.com>
#   (original version based on Nathan Yergler's build script)
# Most recent version is at <http://kb.mozillazine.org/Bash_build_script>

# This script assumes the following directory structure:
# ./
#   dictionaries.xcu
#   (other files listed in $ROOT_FILES)
#
#   META-INF/   |
#
# It uses a temporary directory ./build when building; don't use that!
# Script's output is:
# ./$APP_NAME.oxt
# ./files -- the list of packaged files
#

#
# default configuration file is ./config_build.sh, unless another file is 
# specified in command-line. Available config variables:
APP_NAME=          # short-name, oxt file name. Must be lowercase with no spaces
CLEAN_UP=          # delete the oxt / "files" when done?       (1/0)
ROOT_FILES=        # put these files in root of oxt (space separated list of leaf filenames)
ROOT_DIRS=         # ...and these directories       (space separated list)
BEFORE_BUILD=      # run this before building       (bash command)
AFTER_BUILD=       # ...and this after the build    (bash command)

if [ -z $1 ]; then
  . ./config_build.sh
else
  . $1
fi

if [ -z $APP_NAME ]; then
  echo "You need to create build config file first!"
  echo "Read comments at the beginning of this script for more info."
  exit;
fi

ROOT_DIR=`pwd`
TMP_DIR=build

#uncomment to debug
#set -x

# remove any left-over files from previous build
rm -f $APP_NAME.oxt files
rm -rf $TMP_DIR

$BEFORE_BUILD

mkdir --parents --verbose $TMP_DIR


# prepare components and defaults
echo "Copying various files to $TMP_DIR folder..."
for DIR in $ROOT_DIRS; do
  mkdir $TMP_DIR/$DIR
  FILES="`find $DIR \( -path '*CVS*' -o -path '*.svn*' \) -prune -o -type f -print | grep -v \~`"
  echo $FILES >> files
  cp --verbose --parents $FILES $TMP_DIR
done

# Copy other files to the root of future OXT.
for ROOT_FILE in $ROOT_FILES; do
  cp --verbose $ROOT_FILE $TMP_DIR
  if [ -f $ROOT_FILE ]; then
    echo $ROOT_FILE >> files
  fi
done

cd $TMP_DIR


# generate the OXT file
echo "Generating $APP_NAME.oxt..."
zip -r ../$APP_NAME.oxt *

cd "$ROOT_DIR"

echo "Cleanup..."
if [ $CLEAN_UP = 1 ]; then
  rm ./files
  rm $ROOT_FILES
fi

# remove the working files
rm -rf $TMP_DIR
echo "Done!"

$AFTER_BUILD

