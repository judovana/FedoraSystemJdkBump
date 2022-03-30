#!/bin/sh
if [ "$1" == "" -o  "$1" == "s"  ] ; then 
  echo "strict graph { "
  ls | sed "s/~is~req~by~/\" -- \"/g" | sed "s/^/\"/g" | sed "s/$/\"/g"
  echo "}"
else
  echo "digraph some_chart {"
  ls | sed "s/~is~req~by~/\" -> \"/g" | sed "s/^/\"/g" | sed "s/$/\"/g"
  echo "}"
fi
