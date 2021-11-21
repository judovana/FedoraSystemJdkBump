#!/bin/bash

for file in "$@" ; do
  while IFS= read -r line; do
    d1="${line%-*}"
    d2="${d1%-*}"      
    echo $d2
  done < "$file"
done

