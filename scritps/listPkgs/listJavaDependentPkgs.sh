#!/bin/bash

binRepos="fedora fedora-modular updates updates-modular"
srcRepos="fedora-modular-source fedora-source updates-modular-source updates-source"
interestingDeps="java-headless java java-devel java-1.8.0-openjdk-headless java-1.8.0-openjdk java-1.8.0-openjdk-devel java-11-openjdk-headless java-11-openjdk java-11-openjdk-devel ant maven-local maven mvn xmvn "

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
  echo $TITLE
  rm $FILE
  for x in $interestingDeps ; do
    echo -n " $x "
    local repos=`disableAllEnableGiven $REPOS`
    IFS="
"
    repoquery $RS1 $RS2 $repos -q --whatrequires $x | sort >> $FILE
    cat $FILE | wc -l
    IFS="$IFS_BACKUP"
  done
  echo -n "total: " ; cat $FILE | sort | uniq | wc -l
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

echo "although each pair should return same, they do not. Feel free to compare b1.jbump x b2.jbump and r1.jbump and r2.jbump."
echo "Do not join them, but mix them. '2' is subset of '1'."

cat b1.jbump b2.jbump | sort | uniq > ball.jbump
echo -n " total build: " ; cat ball.jbump | wc -l
cat r1.jbump r2.jbump | sort | uniq > rall.jbump
echo -n " total runtime: " ; cat rall.jbump | wc -l
cat ball.jbump rall.jbump | sort | uniq > all.jbump
echo -n " total: " ; cat all.jbump | wc -l 

echo "see all.jbump (or one of build/runtime ball.jbump/rall.jbump)."
echo "Use that full listing, or at least build listing for initial import to copr repo!"


