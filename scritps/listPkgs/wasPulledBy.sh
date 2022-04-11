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

readOrigin ${@}


