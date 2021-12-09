#!/bin/bash
COPR_REPO=java17
FULL_REPO=jvanek/$COPR_REPO

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

echo "regeneratng. If it is not working, there is button on mainpage of your copr (but have same lag)"
set -x
copr regenerate-repos $COPR_REPO
set +x
echo "Unluckily this is not immedaite. Check by: "
echo "dnf -q --refresh --repofrompath j17,https://copr-be.cloud.fedoraproject.org/results/$FULL_REPO/fedora-rawhide-x86_64 --repo j17 repoquery --qf '%{name}-%{version}-%{release} %{buildtime}' SOME_PKG"
echo "You should see only one occurence of each pkg: "



