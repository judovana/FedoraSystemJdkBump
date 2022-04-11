#!/bin/bash


function readOrigin() {
  if [ $# = 0 ] ; then
    DEFAULT_INPUT_FILE=/dev/stdin
  else
    DEFAULT_INPUT_FILE=
  fi
  for file in "$@" $DEFAULT_INPUT_FILE ; do
    if [ -e $file ] ; then
      while IFS= read -r line; do
        echo "* $line was pulled in by:"
        ls . | grep ~$line$ | sed "s/~is~req~by~.*//"
      done < "$file"
    else
      ls . | grep ~$file$ | sed "s/~is~req~by~.*//"
    fi
  done
}

# there are recursive depndencies unluckily...
# so one would need to coutn anyway
# also we never reached deeper then 5...
# long story short to lazy to do this proeprly
if [ "x$RECURSIVE" == "xtrue" ] ; then
  for orig in "$@" ; do
    current=`readOrigin $orig`
    for x1 in  $current ; do
      current1=`readOrigin $x1`
      for x2 in  $current1 ; do
        current2=`readOrigin $x2`
        for x3 in  $current2 ; do
          current3=`readOrigin $x3`
          for x4 in  $current3 ; do
            current4=`readOrigin $x4`
            for x5 in  $current4 ; do
              echo "$x5 <- $x4 <- $x3 <- $x2 <- $x1 <- $orig"
            done
          done
        done
      done
    done
  done
else
  readOrigin ${@}
fi

