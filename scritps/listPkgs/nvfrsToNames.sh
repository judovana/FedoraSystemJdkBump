#!/bin/bash

if [ $# = 0 ] ; then
  DEFAULT_INPUT_FILE=/dev/stdin
else
  DEFAULT_INPUT_FILE=
fi

tmp=`mktemp`
for file in "$@" $DEFAULT_INPUT_FILE ; do
  while IFS= read -r line; do
    d1="${line%-*}"
    d2="${d1%-*}"
    echo $d2
  done < "$file"
done  | sort | uniq > $tmp

# the check ensures, that only live packages, not ded pkgs nor subpkgs, got to the list
# the check for orphans is done later

if [ "x$SKIP_CHECK" == "x" ] ; then
  while IFS= read -r line; do
    wget -S --spider https://src.fedoraproject.org/rpms/$line 2>&1 | grep -q 'HTTP/1.. 200 OK'
    if [ $? -eq 0 ]; then
      wget -S --spider https://src.fedoraproject.org/rpms/$line/raw/rawhide/f/dead.package 2>&1 | grep -q 'HTTP/1.. 200 OK'
      if [ $? -eq 0 ]; then
        echo "  skipping $line - dead package" >&2
      else
		if [ "x$PRINT_ARCH" = "xtrue" ] ; then
          echo -n $line 
		  a=""
          a=`curl  -s https://src.fedoraproject.org/rpms/$line/raw/rawhide/f/$line.spec`
		  ea=""
		  ea=`echo "$a" | grep ExclusiveArch`
		  echo "$a" | grep ExclusiveArch | grep -q noarch
		  if [ $? -eq 0 ] ; then
			  echo " noarch ($ea)"
		  else
			  echo " archful ($ea)"
		  fi
		else
		  echo $line
		fi
      fi
    else
	  # it may be good idea to remove last -string (dashString eg perl-coomons -> perl)
	  # and proceed recursively, to see if the remain maybe is also package needing eyball
      echo "  skipping $line - subpkg" >&2
	  if [ ! "x$SUBPKGS_FILE" == "x" ] ; then
		  echo $line >> $SUBPKGS_FILE
      fi
    fi
  done < "$tmp"
else
  cat "$tmp"
fi

