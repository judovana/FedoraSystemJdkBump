#!/bin/bash

if [ $# = 0 ] ; then
  DEFAULT_INPUT_FILE=/dev/stdin
else
  DEFAULT_INPUT_FILE=
fi

for file in "$@" $DEFAULT_INPUT_FILE ; do
  while IFS= read -r line; do
    d1="${line%-*}"
    echo $d1-v-r.arch.rpm
  done < "$file"
done  | sort | uniq 

