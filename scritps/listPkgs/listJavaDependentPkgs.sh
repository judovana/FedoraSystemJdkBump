#!/bin/bash

readonly binRepos="fedora fedora-modular updates updates-modular"
readonly srcRepos="fedora-modular-source fedora-source updates-modular-source updates-source"
if [ ! -z "${1}" ] ; then
  readonly interestingDeps=$(echo $(cat ${1})) #to put it to one line
else
  readonly interestingDeps="java-headless java java-devel java-1.8.0-openjdk-headless java-1.8.0-openjdk java-1.8.0-openjdk-devel java-11-openjdk-headless java-11-openjdk java-11-openjdk-devel ant maven-local maven mvn xmvn ivy-local java-17-openjdk-headless java-17-openjdk java-17-openjdk-devel"
fi

#to allow work with repos with spaces in names, IFS is affected manytimes
IFS_BACKUP="$IFS"

function listAllRepos() {
  # warning, localised
  LANG=en_US.UTF-8 dnf repolist all
}

function listAllReposNames() {
  # header in first row, remvoing by tail
  listAllRepos | sed "s/\\s\\{2,1000\\}.*//" | tail -n +2
}

function toEs() {
 for x in "$@" ; do
   echo -n "-e ^$x$ "
 done
   echo
}

function disableAllEnableGiven() {
  local a="`listAllReposNames`"
  local regexes="`toEs "$@"`"
  IFS="
"
  for x in $a ; do
    IFS="$IFS_BACKUP"
    if echo "$x" | grep -q $regexes; then
      echo "--enablerepo=$x"
   else
     echo  "--disablerepo=$x"
    fi
  done
  IFS="$IFS_BACKUP"
}

function doMain() {
  echo $TITLE >&2
  rm $FILE
  for x in $interestingDeps ; do
    echo -n " $x " >&2
    local repos=`disableAllEnableGiven $REPOS`
    IFS="
"
    repoquery $RS1 $RS2 $repos -q --whatrequires $x | sort >> $FILE
    cat $FILE | wc -l >&2
    IFS="$IFS_BACKUP"
  done
  echo -n "total: " ; cat $FILE | sort | uniq | wc -l >&2
  echo ""
}

TITLE="Buildtime depndencies (src repos, all arches): "
FILE=b1.jbump
RS1=
RS2=
REPOS="$srcRepos"
doMain

TITLE="Runtime depndencies (bin repos, all arches): "
FILE=r1.jbump
REPOS="$binRepos"
RS1=
RS2=
doMain

TITLE="Buildtime depndencies (all repos, src arch): "
FILE=b2.jbump
REPOS="$srcRepos $binRepos"
RS1="--arch
src" # IFS ammended
RS2=
doMain

TITLE="Runtime depndencies (all repos, bin arches): "
FILE=r2.jbump
REPOS="$srcRepos $binRepos"
RS1="--arch
x86_64" # IFS ammended
RS2="--arch
noarch" # IFS ammended
doMain

echo "although each pair should return same, they do not. Feel free to compare b1.jbump x b2.jbump and r1.jbump and r2.jbump." >&2
echo "Do not join them, but mix them. '2' is subset of '1'." >&2

cat b1.jbump b2.jbump | sort | uniq > ball.jbump
echo -n " total build: " >&2 ; cat ball.jbump | wc -l >&2
cat r1.jbump r2.jbump | sort | uniq > rall.jbump
echo -n " total runtime: " >&2 ; cat rall.jbump | wc -l >&2
cat ball.jbump rall.jbump | sort | uniq > all.jbump
echo -n " total: " >&2 ; cat all.jbump | wc -l  >&2

cat all.jbump # the only thing whcich shold go to stdout

echo "see all.jbump (or one of build/runtime ball.jbump/rall.jbump)." >&2
echo "Use that full listing, or at least build listing for initial import to copr repo!" >&2
echo "" >&2
echo "Warning: If include only build (b*.jbump) depndencies, then ou are safe. Those are packages" >&2
echo "Warning: If you include also runtime dependencies, then you have to double check it is  not subpkg" >&2
echo "Warning: In all cases you should verify it is not dead package" >&2
echo "Warning: by default, nvfrsToNames.sh have are checking the subpkg AND if the pkg is not dead package" >&2

