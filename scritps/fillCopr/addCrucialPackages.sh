#!/bin/bash

## resolve folder of this script, following all symlinks,
## http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
readonly SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

source ${SCRIPT_DIR}/getCrucialPackages.sh

# pkgs are from sourced getCrucialPackages.sh
for pkg in ${!pkgs[@]}; do
  urlAndBranch=${pkgs[$pkg]};
  branch=`echo "$urlAndBranch" | sed "s/.*\s\+//g"`
  url=`echo "$urlAndBranch" | sed "s/\s\+.*//g"`
  sh ${SCRIPT_DIR}/repoToCopr.sh ${pkg} ${url} ${branch}
done


