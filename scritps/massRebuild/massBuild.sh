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
branch=rawhide
TAG=rawhide
##targettedSelection="CFR"

FILE_WITH_PKGS="$SCRIPT_DIR/../fillCopr/exemplarResults/depndent-packages.jbump"

function compileAndRun() {
  if [ "x$cp" == "x" ] ; then
    cp=`mktemp -d`
    javac -d $cp $SCRIPT_DIR/ChangeRequires.java
  fi
  if [ ! "x$1" == "x" ] ; then
    java -cp $cp ChangeRequires $1
  fi
}

# this gives us aray of packages which needs manual treatment.
# they have to soak into side tag before everything else
source "$SCRIPT_DIR/../fillCopr/getCrucialPackages.sh"
echo "Are you sure all below packages are sucessfully in your side tag $TAG in proper versions?"
echo " * ${!pkgs[@]}"
echo "type yes and enter"
read
if [ ! "x${REPLY}" = "xyes" ] ; then exit 1 ; fi
#lets add few more which builds to long. You will handle them manually later
#for k in icecat rstudio ceph hdf5 libreoffice chromium ; do
#  pkgs[$k]=unused_now
#done
regex=`echo "${!pkgs[@]}" | sed  's;\s\+;$ -e ^;g'`
regex=" -e ^someNonsnense$regex$"
echo "total known packages: "
echo -n " * "
cat $FILE_WITH_PKGS | wc -l
echo "total known packages afer exclusion: "
echo -n " * "
cat $FILE_WITH_PKGS | grep  -v $regex | grep "$targettedSelection" | wc -l
echo "dont forget to handle following packages manually!"
echo " * " ${!pkgs[@]}
compileAndRun
RESULTS_DIR="$SCRIPT_DIR/results"
echo "CLONE=$CLONE COMMITED=$COMMITED KEEP=$KEEP"
echo "DO=$DO targettedSelection=$targettedSelection TAG=$TAG"
echo "Are you kinit into FEDORAPROJECT.ORG? Are you proven packager? Do you really wish to run in branch $branch?"
echo "type yes and enter. If you are not proven packager, it will fail on foreign pkgs. This will discard all old results $RESULTS_DIR"
read
if [ ! "x${REPLY}" = "xyes" ] ; then exit 1 ; fi
rm -rf "$RESULTS_DIR"
mkdir  "$RESULTS_DIR"
echo "starting mass rebuild for $TAG"
set +e # disputable... but yo do not want to lost 24h long script becasue of minute network issue i second hour
#inspired by https://github.com/hroncok/mini-mass-rebuild ... fedpkg-bump-build.sh I think
# if you wish to run it on some set of pkgs - eg on the keys from above - copy this script, and replace below `cat...` by hardcoded list

for pkg in `cat $FILE_WITH_PKGS | grep  -v $regex  | grep "$targettedSelection"` ; do 
  if [ "x$CLONE" == "xfalse" ] ; then
    ls -l -d $pkg
  else
    fedpkg clone $pkg  2>&1 | tee $RESULTS_DIR/${pkg}.log
  fi
  pushd $pkg
    git checkout $branch
    MSG_TITLE="Rebuilt for java-25-openjdk as preffered jdk"
    MSG="$MSG_TITLE

https://fedoraproject.org/wiki/Changes/Java25AndNoMoreSystemJdk
Note, that since f43, you should be always explicit on what jdk to use.
This commit should do exactly that.
"
    if [ "x$COMMITED" == "xtrue" ] ; then
      echo "Skipping commit on demand"
    else
      compileAndRun $pkg.spec
      rpmdev-bumpspec -c "$MSG_TITLE" $pkg.spec | tee -a $RESULTS_DIR/${pkg}.log
      git diff
      git commit --allow-empty ${pkg}.spec -m "$MSG" | tee -a $RESULTS_DIR/${pkg}.log
    fi
    if [ "x$DO" == "xtrue" -o "x$DO" == "xscratch" ] ; then
      if [ "x$DO" == "xscratch" ] ; then
        fedpkg build  --target $TAG --fail-fast --nowait --background --scratch --srpm 2>&1 | tee -a $RESULTS_DIR/${pkg}.log
      else
        git push | tee -a $RESULTS_DIR/${pkg}.log
        fedpkg build  --target $TAG --fail-fast --nowait --background 2>&1 | tee -a $RESULTS_DIR/${pkg}.log
      fi
      TASK=`cat $RESULTS_DIR/${pkg}.log  | grep "Created task: " | sed "s/.*: //"`
      koji watch-task $TASK >> $RESULTS_DIR/${pkg}.log &
      sleep 20
    else
      fedpkg srpm | tee -a $RESULTS_DIR/${pkg}.log
      rpmbuild --rebuild $pkg*.src.rpm 2>&1 | tee -a $RESULTS_DIR/${pkg}.log # this is nearly irrelevant, as it do not even use sidetag but good enough to verify commit and so
    fi
  popd
  if [ "x$CLONE" == "xfalse" ] ; then
    ls -l -d $pkg
  else
    if [ "x$KEEP" == "xtrue" ] ; then
      ls -l -d $pkg
    else
      rm -rf $pkg
    fi
  fi
  processes=`ps | wc -l`
  while [ $processes -gt 50 ] ; do 
    processes=`ps | wc -l`
    echo "to much processes - $processes, waiting"
    sleep 10
  done
done

