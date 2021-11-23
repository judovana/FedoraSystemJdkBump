#!/bin/bash
COPR_REPO=jvanek/java17
pkg=${1} # java-runtime-decompiler
URL=${2} # https://src.fedoraproject.org/rpms/${pkg}.git
BRANCH=${3} # master

echo "adding $URL#$BRANCH as $pkg into $COPR_REPO"
copr add-package-scm --clone-url ${URL} --name ${pkg} --webhook-rebuild on --commit ${BRANCH}  ${COPR_REPO}
if [ $? -gt 0 ] ; then
  echo "adding failed, trying to modify"
  copr edit-package-scm --clone-url ${URL} --name ${pkg} --webhook-rebuild on --commit ${BRANCH} ${COPR_REPO}
  if [ $? -gt 0 ] ; then
    echo "modification failed. Wrong pkg, url branch?"
  fi
fi
