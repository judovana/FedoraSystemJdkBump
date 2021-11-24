#!/bin/bash

tmp=`mktemp`
for file in "$@" ; do
  while IFS= read -r line; do
    d1="${line%-*}"
    d2="${d1%-*}"
    echo $d2
  done < "$file"
done  | sort | uniq > $tmp

# if jsut build dependencies were scanned, then all should be ok
# if also runtime depndencies were scanned, then the below check should be used
# otherwise a subpkg may thenbe tried to be forced to copr/searched for maintainer


if [ "x$FORCE_CHECK" == "x" ] ; then
  cat "$tmp"
else
  while IFS= read -r line; do
    wget -S --spider https://src.fedoraproject.org/rpms/$line 2>&1 | grep -q 'HTTP/1.. 200 OK'
    if [ $? -eq 0 ]; then
      echo $line
    else
      echo "  skipping $line - subpkg" >&2
    fi
  done < "$tmp"
fi

