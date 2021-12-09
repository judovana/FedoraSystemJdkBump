#!/bin/bash
COPR_REPO=java17

sep="#"
if [ "x$1" == "x" ]; then
  f=`mktemp`
  copr list-builds --output-format text-row $COPR_REPO > $f
else
  f=$1
fi
echo $f >&2
cat $f >&2
declare -A pkgWithBuilds
declare -A mostFreshPassedBuildOfPkg
while IFS= read -r line; do
  line=`echo $line | sed "s;\\s\\+;$sep;g"`
  id=`echo $line | cut -d "$sep" -f 1`
  pkg=`echo $line | cut -d "$sep" -f 2`
  status=`echo $line | cut -d "$sep" -f 3`
  if [ "x$status" == "xsucceeded" ] ; then
    pkgWithBuilds[$pkg]="${pkgWithBuilds[$pkg]} $id "
    if [ "x${mostFreshPassedBuildOfPkg[$pkg]}" = "x" ] ; then
      mostFreshPassedBuildOfPkg[$pkg]="$id"  #the output is sorted, so storing the first sucess == storing the most fresh build
    fi
    echo "$pkg (${mostFreshPassedBuildOfPkg[$pkg]}): ${pkgWithBuilds[$pkg]}"
  else
    echo "skipped $status/$id of $pkg"
  fi
done < $f

for pkg in "${!pkgWithBuilds[@]}"; do
  for build in ${pkgWithBuilds[$pkg]} ;  do
    if [ $build == ${mostFreshPassedBuildOfPkg[$pkg]} ] ; then
      echo "skipping: $build of $pkg"  
    else
      echo "deleting: $build of $pkg"
      copr delete-build $build
    fi
  done
done
