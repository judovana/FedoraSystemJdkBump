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

set -e
set -o pipefail


function analyse() {
  aa=`ls */*.spec | wc -l`
  a=0
  set +e
  for x in `ls */*.spec` ; do
    let a=a+1;
    echo "  ** $x $a/$aa**" ;
    cat $x | grep -e "^BuildRequires:" -e "^Requires:" | grep -v -e "mvn(" -e unit -e plugin| grep -e java-headless -e java -e java-devel -e maven-local -e maven -e mvn -e xmvn -e ivy-local -e ant -e java-21-openjdk-headless -e java-21-openjdk -e java-21-openjdk-devel -e javapackages-local-openjdk21 -e javapackages-local -e ant -e ant-local-openjdk21 ;
    if [ $? -ne 0 ] ; then
      echo "no hit in $x!!"
    fi
  done
}

workDir=work
cp=`mktemp -d`
javac -d $cp ChangeRequires.java

if [ ! -e $workDir ] ; then
  mkdir $workDir
  pushd $workDir
    a=`cat $SCRIPT_DIR/../fillCopr/exemplarResults/depndent-packages.jbump`
    for x in $a ; do
      fedpkg clone $x
    done
  popd
fi

cd $workDir

if [ "x$RESET" == "xtrue" ] ; then
  for x in `find  -maxdepth 1 -mindepth 1 -type d | more` ; do
    pushd $x;
      git reset --hard
    popd
  done
fi

analyse
java -cp $cp ChangeRequires `ls */*.spec`

for x in `find  -maxdepth 1 -mindepth 1 -type d | more` ; do
  pushd $x;
    git diff
  popd
done
