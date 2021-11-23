#!/bin/bash
declare -A pkgs

if [ "x$ALL_MERGED" == "x" ] ; then
  k=java-latest-openjdk
  pkgs[$k]="https://src.fedoraproject.org/forks/jvanek/rpms/$k.git java-17-openjdk"
  k=java-11-openjdk
  pkgs[$k]="https://src.fedoraproject.org/forks/jvanek/rpms/$k.git nolongerSystemJDk"
  k=javapackages-tools
  pkgs[$k]="https://src.fedoraproject.org/forks/mizdebsk/rpms/$k.git jdk17-as-default"
  k=maven
  pkgs[$k]="https://src.fedoraproject.org/forks/mizdebsk/rpms/$k.git jdk17-as-default"
  k=xmvn
  pkgs[$k]="https://src.fedoraproject.org/forks/mizdebsk/rpms/$k.git jdk17-as-default"
else 
  default_fedora_url="https://src.fedoraproject.org/rpms"
  default_branch="master"
  k=java-latest-openjdk
  pkgs[$k]="$default_fedora_url/$k.git master"
  k=java-11-openjdk
  pkgs[$k]="$default_fedora_url/$k.git master"
  k=javapackages-tools
  pkgs[$k]="$default_fedora_url/$k.git master"
  k=maven
  pkgs[$k]="$default_fedora_url/$k.git master"
  k=xmvn
  pkgs[$k]="$default_fedora_url/$k.git master"
fi
