#!/bin/bash

# Dot forget to adjust commit message!

set -e
set -o pipefail

pkgsFile=$1
if [ "x$pkgsFile" == "x" ] ; then
  echo "single file with pkgs is mandatory"
  exit 2
fi

branch=rawhide
MSG_TITLE="bump of release for for java-21-openjdk as system jdk"
MSG="$MSG_TITLE

https://fedoraproject.org/wiki/Changes/Java21
We are sorry, we messed a bit, and we have to bump release in this package
"


count=`cat $pkgsFile | wc -l`
echo "All pkgs in $pkgsFile file ($count pkgs) will receive release bump in $branch, changelog message and commit. Are you sure to proced?"
echo "Message:"
echo "$MSG"
echo "type yes and enter"
read
if [ ! "x${REPLY}" = "xyes" ] ; then exit 1 ; fi
RESULTS_DIR="$PWD/results"
rm -rf "$RESULTS_DIR"
mkdir  "$RESULTS_DIR"
echo "starting mass release bump"
set +e # disputable... but yo do not want to lost 24h long script becasue of minute network issue i second hour
#inspired by https://github.com/hroncok/mini-mass-rebuild ... fedpkg-bump-build.sh I think
for pkg in `cat $pkgsFile` ; do 
  pushd $RESULTS_DIR
  fedpkg clone $pkg  2>&1 | tee $RESULTS_DIR/${pkg}.log
  pushd $pkg
    git checkout $branch
    rpmdev-bumpspec -c "$MSG_TITLE" $pkg.spec | tee -a $RESULTS_DIR/${pkg}.log
    git commit --allow-empty ${pkg}.spec -m "$MSG" | tee -a $RESULTS_DIR/${pkg}.log
    if [ "x$DO" == "xtrue" ] ; then
      git push | tee -a $RESULTS_DIR/${pkg}.log
      sleep 2
   else
     echo "not pushing, no DO=true; check results"
   fi
  popd
  popd
done

