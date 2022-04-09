#!/bin/bash

if [ $# = 0 ] ; then
  DEFAULT_INPUT_FILE=/dev/stdin
else
  DEFAULT_INPUT_FILE=
fi
for file in "$@" $DEFAULT_INPUT_FILE ; do
  while IFS= read -r line; do
    echo "* $line was pulled in by:"
    ls . | grep ~$line$ | sed "s/~is~req~by~.*//"
  done < "$file"
done


