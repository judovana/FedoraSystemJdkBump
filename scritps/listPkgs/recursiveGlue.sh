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

# this will remove content of f1 from f2
function remove1from2() {
  local f1=${1}
  local f2=${2}
  grep -v -x -f ${f1} ${f2}
}

function filter2by1() {
  local f1=${1}
  local f2=${2}
  cp ${f2} ${f2}.backup
  remove1from2 ${f1} ${f2}.backup >  ${f2}
  rm ${f2}.backup
}

if [ "x$SCANNED" = "xtrue" ] ; then
  echo "skipping all repoquery, processing existing tierX and allWhatever files:"
else
  # summ up all. that wil be used fore i686 leaves and for final statistics
  # note, that this do not honor the complex repos work as listJavaDependentPkg.sh does. But that do nto hurt at all...
  dnf list all  | sed "s/\s.*//g" > all.nvras
  cat all.nvras | grep -v "\.noarch" > all-archfull.nvras
  cat all.nvras | grep -e "\.noarch" > all-noarch.nvras
  cat all.nvras | grep -e "\.i686" > all-multilib.nvras

  # find transitive depndencies 
  # will skip check on dead packages and subpackages in nvfrsToNames.sh
  export SKIP_CHECK=true;
  export CHART=$PWD/edges;

  rm -rf $CHART
  mkdir  $CHART

  # initial load, all what depends on java, mvn and friends in 
  # build or runtime. result is all.jbump
  # cat $SCRIPT_DIR/listJavaDependentPkgs.sh | grep interestingDeps=\" | sed "s/.*interestingDeps=\"//" | sed "s/\".*//" | sed "s/\s\+/\n/g" >  tier0.names
  echo "java
java-17
java-17-openjdk
java-openjdk
jre
jre-17
jre-17-openjdk
jre-openjdk
java-17-demo
java-17-openjdk-demo
java-demo
java-openjdk-demo
java-17-devel
java-17-openjdk-devel
java-devel
java-devel-openjdk
java-sdk
java-sdk-17
java-sdk-17-openjdk
java-sdk-openjdk
java-17-headless
java-17-openjdk-headless
java-headless
java-openjdk-headless
jre-17-headless
jre-17-openjdk-headless
jre-headless
jre-openjdk-headless
libjava.so
libjsig.so
libjvm.so
libjvm.so
libsyslookup.so
libverify.so
java-17-javadoc
java-17-openjdk-javadoc
java-javadoc
java-17-openjdk-javadoc-zip
java-17-jmods
java-17-openjdk-jmods
java-jmods
java-17-openjdk-src
java-17-src
java-openjdk-src
java-src
java-11
java-11-openjdk
jre-11
jre-11-openjdk
java-11-demo
java-11-openjdk-demo
java-11-devel
java-11-openjdk-devel
java-sdk-11
java-sdk-11-openjdk
java-11-headless
java-11-openjdk-headless
jre-11-headless
jre-11-openjdk-headless
java-11-javadoc
java-11-openjdk-javadoc
java-11-openjdk-javadoc-zip
java-11-jmods
java-11-openjdk-jmods
java-11-openjdk-src
java-11-src
java-1.8.0
java-1.8.0-openjdk
jre-1.8.0
jre-1.8.0-openjdk
java-1.8.0-demo
java-1.8.0-openjdk-demo
java-1.8.0-devel
java-1.8.0-openjdk-devel
java-sdk-1.8.0
java-sdk-1.8.0-openjdk
java-1.8.0-headless
java-1.8.0-openjdk-headless
jre-1.8.0-headless
jre-1.8.0-openjdk-headless
java-1.8.0-javadoc
java-1.8.0-openjdk-javadoc
java-1.8.0-openjdk-javadoc-zip
java-1.8.0-jmods
java-1.8.0-openjdk-jmods
java-1.8.0-openjdk-src
java-1.8.0-src" >  tier0.names

  # it may happen, that (eg by incorrect spec file) that also transitive depndence is included as top level depndence
  # eg something requires ant and java. However and already requires java, so suddenly we will have java deps listed in all tier, which we do not want
  for x in `seq 1 11` ; do
    base=$(($x-1))
    export CHART_TIER=$x
    sh $SCRIPT_DIR/listJavaDependentPkgs.sh tier$base.names
    cat all.jbump | sh $SCRIPT_DIR/nvfrsToNames.sh >  tier$x.names
    cp tier$x.names tier$x-all.names # jsut for case...
    # now  remove all already walked through guys. On tier 1 it do nearly nothing (but eg removal of ant and java put next walk to less then half).As conseqence, on two and up it removes huge numbers
    for y in `seq 0 $base` ; do
      filter2by1 tier$y.names tier$x.names
    done
    cp all.jbump all$x.names # jsut for case...
  done
fi
