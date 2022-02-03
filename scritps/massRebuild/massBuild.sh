#!/bin/bash

# Dot forget to adjust commit message!

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

set -e
set -o pipefail
TAG=f36-java17
FILE_WITH_PKGS="$SCRIPT_DIR/../fillCopr/exemplarResults/depndent-packages.jbump"

# this gives us aray of packages which needs manual treatment.
# they have to soak into side tag before everything else
source "$SCRIPT_DIR/../fillCopr/getCrucialPackages.sh"
echo "Are you sure all below packages are sucessfully in your side tag $TAG in proper versions?"
echo " * ${!pkgs[@]}"
echo "type yes and enter"
read
if [ ! "x${REPLY}" = "xyes" ] ; then exit 1 ; fi
#lets add few more which builds to long. You will handle them manually alter
for k in icecat rstudio ceph hdf5 libreoffice  py4j chromium ; do
  pkgs[$k]=unused_now
done
regex=`echo "${!pkgs[@]}" | sed  's;\s\+;$ -e ^;g'`
regex=" -e ^someNonsnense$regex$"
echo "total known packages: "
echo -n " * "
cat $FILE_WITH_PKGS | wc -l
echo "total known packages afer exclusion: "
echo -n " * "
cat $FILE_WITH_PKGS | grep  -v $regex | wc -l
echo "dont forget to handle following packages manually!"
echo " * " ${!pkgs[@]}
RESULTS_DIR="$PWD/results"
echo "press yes and enter. If you are not proven packager, it will fail. This will discard all old results $RESULTS_DIR"
read
if [ ! "x${REPLY}" = "xyes" ] ; then exit 1 ; fi
rm -rf "$RESULTS_DIR"
mkdir  "$RESULTS_DIR"
echo "starting mass rebuild for $TAG"
#inspired by https://github.com/hroncok/mini-mass-rebuild ... fedpkg-bump-build.sh I think
for pkg in `cat $FILE_WITH_PKGS | grep  -v $regex ` ; do 
  fedpkg clone $pkg  2>&1 | tee $RESULTS_DIR/${pkg}.log
  pushd $pkg
    MSG="Rebuilt for java-17-openjdk as system jdk"
    DO="false"
    rpmdev-bumpspec -c "$MSG" $pkg.spec | tee -a $RESULTS_DIR/${pkg}.log
    git commit ${pkg}.spec -m "$MSG" | tee -a $RESULTS_DIR/${pkg}.log
    if [ "x$DO" == "xtrue" ] ; then
      git push | tee -a $RESULTS_DIR/${pkg}.log
      fedpkg build  --target $TAG --fail-fast --nowait --background 2>&1 | tee -a $RESULTS_DIR/${pkg}.log
      sleep 60
    else
      fedpkg srpm | tee -a $RESULTS_DIR/${pkg}.log
      rpmbuild --rebuild $pkg*.src.rpm 2>&1 | tee -a $RESULTS_DIR/${pkg}.log
    fi
  popd
  rm -rf $pkg
done

