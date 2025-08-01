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

readonly binRepos="fedora fedora-modular updates updates-modular"
readonly srcRepos="fedora-modular-source fedora-source updates-modular-source updates-source"
if [ ! -z "${1}" ] ; then
  readonly interestingDeps=$(echo $(cat ${1})) #to put it to one line
else
  readonly interestingDeps="java-headless java java-devel maven-local maven mvn xmvn ivy-local ant java-21-openjdk-headless java-21-openjdk java-21-openjdk-devel javapackages-local-openjdk21 javapackages-local ant ant-local-openjdk21"
fi

#to allow work with repos with spaces in names, IFS is affected manytimes
IFS_BACKUP="$IFS"

function listAllRepos() {
  # warning, localised
  LANG=en_US.UTF-8 dnf repolist --all
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
    local dfile=`mktemp`
    repoquery $RS1 $RS11 $RS2 $repos -q --whatrequires $x | sort > $dfile
    if [ ! "x$CHART" == "x" ] ; then
      cp $dfile $dfile-backup1
      cat $dfile-backup1 | sh $SCRIPT_DIR/nvfrsToNames.sh > $dfile
      for line in `cat $dfile` ; do
        local from=`cat all.nvras | grep -v ".src$" | grep  "^$x\."    | sed "s/.*\.//g" | head -n 1`
        local   to=`cat all.nvras | grep -v ".src$" | grep  "^$line\." | sed "s/.*\.//g" | head -n 1`
        if [ -z "$from" ] ; then  from="i686" ; fi #virtual provide
        if [ -z "$to" ] ; then  to="???" ; fi #should not happen
        local skipnoarchbr=false
        if [ ! "x$SKIP_NOARCH_BR" == "x" ] ; then
          if [ "$CHARTID" == "sa" -o "$CHARTID" == "as" ] ; then
            if [ "$to" == "noarch" ] ; then
              echo "  will skip $line, is $to and buildtime only and thus harmless" >&2
              echo "$line" >> $SKIP_NOARCH_BR
              skipnoarchbr=true
              grep -v -x -f $SKIP_NOARCH_BR $dfile > $dfile-backup2 #this is slow, and not nice, but file was already read  and I started to ahte bash again. Stil the slowest hting around is repoquery
              cp $dfile-backup2 $dfile
            fi
          fi
        fi
        if [ $skipnoarchbr == false ] ; then
          local edgeFile=$CHART/$x~is~req~by~$line
          if [ ! -e $edgeFile ] ; then
            echo "$from~is~req~by~$to" >> $edgeFile
            echo "#tier reqOrigin1 reqOrigin2" >> $edgeFile
          fi
          echo $CHART_TIER $CHARTID $FILE >> $edgeFile
        fi
      done
    rm -f $dfile-backup1 $dfile-backup1
    fi
    cat $dfile >> $FILE
    rm $dfile
    cat $FILE | wc -l >&2
    IFS="$IFS_BACKUP"
  done
  echo -n "total: " ; cat $FILE | sort | uniq | wc -l >&2
  echo ""
}

TITLE="Buildtime depndencies (src repos, all arches): "
CHARTID="sa"
FILE=b1.jbump
RS1=
RS11=
RS2=
REPOS="$srcRepos"
doMain

TITLE="Runtime depndencies (bin repos, all arches): "
CHARTID="ba"
FILE=r1.jbump
REPOS="$binRepos"
RS1=
RS11=
RS2=
doMain

TITLE="Buildtime depndencies (all repos, src arch): "
CHARTID="as"
FILE=b2.jbump
REPOS="$srcRepos $binRepos"
RS1="--arch
src" # IFS ammended
RS11=
RS2=
doMain

TITLE="Runtime depndencies (all repos, bin arches): "
CHARTID="ab"
FILE=r2.jbump
REPOS="$srcRepos $binRepos"
RS1="--arch
x86_64" # IFS ammended
RS11="--arch
i686" # IFS ammended
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

