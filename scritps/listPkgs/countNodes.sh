#!/bin/sh

declare -A countOfChilds
declare -A countOfParents

f1=`mktemp`
f2=`mktemp`

function save() {
  echo "writign $f1 (count of parents) and $f2 (count of children) "
  echo -n > $f1
  echo -n > $f2
  for key in "${!countOfParents[@]}"; do
    echo  "${countOfParents[$key]}  ${key}" >> $f1
  done
  for key in "${!countOfChilds[@]}"; do
    echo  "${countOfChilds[$key]}  ${key}"  >> $f2
  done
  echo "pkgs with most dependencies: cat $f1 | sort -h | tail "
  echo "pkgs which is most required: cat $f2 | sort -h | tail "
}


#perl-Moo~is~req~by~perl-Dancer2
total=`ls . | wc -l`
counter=0;
for item in  `ls .`; do

  let counter=$counter+1
  let nth=$counter%1000
  if [ $nth = 0 ] ; then
    echo $counter"/"$total
    save
  fi

  pkgRequired=$(echo $item | sed "s;~is~req~by~.*;;" )
  pkgRequiring=$(echo $item | sed "s;.*~is~req~by~;;" );

  item=${countOfParents[$pkgRequiring]}
  if [ "x$item" == "x" ] ; then
    item=0
  fi
  let item=$item+1
  countOfParents[$pkgRequiring]=$item

  item=${countOfChilds[$pkgRequired]}
  if [ "x$item" == "x" ] ; then
    item=0
  fi
  let item=$item+1
  countOfChilds[$pkgRequired]=$item
done

echo $counter"/"$total
save
