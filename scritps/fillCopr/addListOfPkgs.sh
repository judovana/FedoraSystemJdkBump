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

defaultFile="$SCRIPT_DIR/exemplarResults/depndent-packages.jbump"
if [ "x$1" == "x" ] ; then
  if [ -e "$defaultFile" ] ; then
    echo "using default file $defaultFile" >&2
    PKGS_FILE=${defaultFile}
  else
    echo "list of nvrs  not present"
    echo "use: ../listPkgs/listJavaDependentPkgs.sh | ../listPkgs/nvfrsToNames.sh > depndent-packages.jbump"
    echo "to generate one"
    exit 1
  fi
else
  PKGS_FILE=${1}
fi


if [ "x$INCLUDE_ORPHANS" == "x" ] ; then
  # Stolen from:
  #  https://pagure.io/user/churchyard/projects -> https://pagure.io/fedora-misc-package-utilities
  # -> https://pagure.io/fedora-misc-package-utilities/raw/master/f/find-orphaned-packages
  # -> https://pagure.io/fedora-misc-package-utilities/raw/master/f/find-package-maintainers
  # the find-orphaned-packages have weird requires, so using find-package-maintainers
  if [ "x$MAINTAINERS_FILE" == "x" ] ; then
    if [ ! -e find-package-maintainers ] ; then
      wget https://pagure.io/fedora-misc-package-utilities/raw/master/f/find-package-maintainers -O find-package-maintainers
    fi
    MAINTAINERS_FILE=maintainers.jbump
    python find-package-maintainers ${PKGS_FILE} > $MAINTAINERS_FILE
    ORPHANS="`cat $MAINTAINERS_FILE | grep  "^orphan\s\+" | sed "s/^orphan\s\+//"`"
  fi
else
  ORPHANS=""
fi

# to list packages which have to be skiped from listing
source ${SCRIPT_DIR}/getCrucialPackages.sh

# pkgs are from above sourced getCrucialPackages.sh
for pkg in `cat $PKGS_FILE`; do
  echo " * $pkg * "
  if echo " $ORPHANS " | grep -q " $pkg "; then
    echo "skipping $pkg, orphan"
    continue
  fi
  if echo " ${!pkgs[@]} " | grep -q " $pkg "; then
    echo "skipping $pkg, crucial pacakge"
    continue
  fi
  branch=rawhide
  url=https://src.fedoraproject.org/rpms/${pkg}.git
  sh ${SCRIPT_DIR}/repoToCopr.sh ${pkg} ${url} ${branch}
done


