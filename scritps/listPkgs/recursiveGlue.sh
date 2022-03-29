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


# summ up all. that wil be used fore i686 leaves and for final statistics
# note, that this do not honor the complex repos work as listJavaDependentPkg.sh does. But that do nto hurt at all...
dnf list all > all.nvras
cat all.nvras | grep -v "\.noarch" > all-archfull.nvras
cat all.nvras | grep -e "\.noarch" > all-noarch.nvras
cat all.nvras | grep -e "\.i686" > all-multilib.nvras

# find transitive depndencies 
# will skip check on dead packages and subpackages in nvfrsToNames.sh
export SKIP_CHECK=true;

# initial load, all what depends on java, mvn and friends in 
# build or runtime. result is all.jbump
cat $SCRIPT_DIR/listJavaDependentPkgs.sh | grep interestingDeps=\" | sed "s/.*interestingDeps=\"//" | sed "s/\".*//" | sed "s/\s\+/\n/g" >  tier0.names


# it may happen, that (eg by incorrect spec file) that also transitive depndence is included as top level depndence
# eg something requires ant and java. However and already requires java, so suddenly we will have java deps listed in all tier, which we do not want
for x in `seq 1 11` ; do
  base=$(($x-1))
  sh $SCRIPT_DIR/listJavaDependentPkgs.sh tier$base.names
  cat all.jbump | sh $SCRIPT_DIR/nvfrsToNames.sh >  tier$x.names
  cp tier$x.names  >  tier$x-all.names # jsut for case...
  # now  remove all already walked through guys. On tier 1 it do nearly nothing (but eg removal of ant and java put next walk to less then half).As conseqence, on two and up it removes huge numbers
  for x in `seq 0 $base` ; do
    filter2by1 tier$y.names tier$x.names
  done
  cp all.jbump  >  all$x.names # jsut for case...
done
