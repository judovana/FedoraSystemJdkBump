#!/bin/bash

## resolve folder of this script, following all symlinks,
## http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
readonly SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

set -e
set -o pipefail

workDir=work

if [ ! -e $workDir ] ; then
  mkdir $workDir
  pushd $workDir
    a=`cat $SCRIPT_DIR/../fillCopr/exemplarResults/depndent-packages.jbump`
    for x in $a ; do
      fedpkg clone $x
    done
  popd
fi

cd $workDir
aa=`ls */*.spec | wc -l`
a=0
set +e
for x in `ls */*.spec` ; do
  let a=a+1;
  echo "  ** $x $a/$aa**" ;
  cat $x | grep -e "^BuildRequires:" -e "^Requires:" | grep -v -e "mvn(" -e unit -e plugin| grep -e java-headless -e java -e java-devel -e maven-local -e maven -e mvn -e xmvn -e ivy-local -e ant -e java-21-openjdk-headless -e java-21-openjdk -e java-21-openjdk-devel -e javapackages-local-openjdk21 -e javapackages-local -e ant -e ant-local-openjdk21 ;
  if [ $? -ne 0 ] ; then
    echo "no hit in $x!!"
  fi
done

###################################################
#  ** ant-contrib/ant-contrib.spec 1/78**
#BuildRequires:  ivy-local
#BuildRequires:  java-devel
#Requires:       java-headless
#Requires:       ant
#  ** antlrworks/antlrworks.spec 2/78**
#BuildRequires:  maven-local
#Requires:       java-devel >= 1:1.6.0
#Requires:       javapackages-tools
#  ** apache-ivy/apache-ivy.spec 3/78**
#BuildRequires:  ant
#BuildRequires:  ivy-local
#BuildRequires:  java-11-devel
#  ** beansbinding/beansbinding.spec 4/78**
#BuildRequires:  ant
#BuildRequires:  java-devel
#Requires:       java >= 1:1.6.0
#Requires:       javapackages-tools
#  ** bolzplatz2006/bolzplatz2006.spec 5/78**
#BuildRequires:  ant sdljava dom4j vecmath1.2 swig xml-commons-apis
#BuildRequires:  java-devel
#Requires:       sdljava dom4j vecmath1.2 java jpackage-utils
#  ** brazil/brazil.spec 6/78**
#BuildRequires:    java-devel
#BuildRequires:    ant
#Requires:         java-headless
#  ** bsh/bsh.spec 7/78**
#BuildRequires:  ant
#BuildRequires:  javacc
#BuildRequires:  javapackages-local
#Requires:       java-headless
#Requires:       javapackages-tools
#  ** byteman/byteman.spec 8/78**
#BuildRequires:    java-devel >= 1:11
#BuildRequires:    maven-local
#BuildRequires:    maven-surefire-provider-testng
#BuildRequires:    java_cup
#Requires:         java-headless >= 1:1.8
#  ** cambozola/cambozola.spec 9/78**
#BuildRequires:  java-devel
#BuildRequires:  ant
#Requires:       java
#  ** CardManager/CardManager.spec 10/78**
#BuildRequires:  java-devel
#BuildRequires:  ant
#Requires:       java
#  ** CFR/CFR.spec 11/78**
#BuildRequires:  maven-local
#Requires:       java-headless
#Requires:       javapackages-tools
#  ** colossus/colossus.spec 12/78**
#BuildRequires:  java-devel
#BuildRequires:  ant
#Requires:       java
#  ** console-image-viewer/console-image-viewer.spec 13/78**
#BuildRequires: java-devel
#BuildRequires: ant
#Requires: java
#Requires: javapackages-tools
#  ** cortado/cortado.spec 14/78**
#BuildRequires:  jpackage-utils java-devel jorbis
#Requires:       java jpackage-utils jorbis
#  ** ditaa/ditaa.spec 15/78**
#BuildRequires:  java-devel >= 1:1.6.0
#BuildRequires:  ant
#Requires:       java-headless >= 1:1.6.0
#  ** dom4j/dom4j.spec 16/78**
#BuildRequires:  maven-local
#  ** eclipse-swt/eclipse-swt.spec 17/78**
#Requires:       java-headless
#BuildRequires:  javapackages-tools
#BuildRequires:  java-devel
#BuildRequires:  maven-local
#BuildRequires:  ant
#  ** fernflower/fernflower.spec 18/78**
#BuildRequires:  javapackages-tools
#BuildRequires:  java-devel
#Requires:      java-headless
#Requires:      javapackages-tools
#Requires: javapackages-filesystem
#  ** flute/flute.spec 19/78**
#BuildRequires: ant, java-devel, jpackage-utils, sac
#Requires: java-headless, jpackage-utils sac
#  ** fop/fop.spec 20/78**
#Requires:       java
#Requires:       javapackages-tools
#BuildRequires:  javapackages-local
#BuildRequires:  maven-local
#  ** freecol/freecol.spec 21/78**
#BuildRequires:  ant xml-commons-apis xml-commons-resolver
#BuildRequires:  java-devel >= 1:17.0.0
#Requires:       java >= 1:17.0.0 jpackage-utils hicolor-icon-theme
#  ** freemarker/freemarker.spec 22/78**
#BuildRequires:  ant
#BuildRequires:  ivy-local
#BuildRequires:  java-1.8.0-openjdk
#BuildRequires:  java-11-openjdk-devel
#  ** freerouting/freerouting.spec 23/78**
#BuildRequires:  java-devel >= 1:1.8
#Requires:       java >= 1:1.8
#  ** hid4java/hid4java.spec 24/78**
#Requires: java-headless
#BuildRequires: maven-local
#  ** icedtea-web/icedtea-web.spec 25/78**
#BuildRequires:     java-%{java_version}-openjdk-devel
#BuildRequires:     javapackages-local
#BuildRequires:     javapackages-tools
#Requires:          java-%{java_version}-openjdk
#Requires:          javapackages-tools
#  ** imagej/imagej.spec 26/78**
#BuildRequires:  ant
#BuildRequires:  java-devel
#Requires:       java-devel
#  ** IPAddress/IPAddress.spec 27/78**
#BuildRequires:  maven-local
#BuildRequires:  ant
#BuildRequires:  java-11-openjdk-devel
#Requires: java-headless
#  ** java-21-openjdk/java-21-openjdk.spec 28/78**
#Requires: javapackages-filesystem
#Requires: tzdata-java >= 2024a
#BuildRequires: javapackages-filesystem
#BuildRequires: tzdata-java >= 2022g
#Requires: javapackages-filesystem
#Requires: javapackages-filesystem
#  ** javapackages-bootstrap/javapackages-bootstrap.spec 29/78**
#BuildRequires:  java-25-openjdk-devel
#Requires:       java-25-openjdk-devel
#Requires:       javapackages-common
#  ** javapackages-tools/javapackages-tools.spec 30/78**
#Requires:       javapackages-filesystem = %{version}-%{release}
#Requires:       java-21-openjdk-devel
#Requires:       javapackages-local-openjdk21 = %{version}-%{release}
#Requires:       xmvn-minimal
#Requires:       xmvn-toolchain-openjdk21
#Requires:       java-25-openjdk-devel
#Requires:       javapackages-local-openjdk25 = %{version}-%{release}
#Requires:       xmvn-minimal
#Requires:       xmvn-toolchain-openjdk25
#Requires:       javapackages-local = %{version}-%{release}
#Requires:       xmvn-connector-ivy
#Requires:       javapackages-common = %{version}-%{release}
#Requires:       xmvn-tools
#Requires:       java-21-openjdk-devel
#Requires:       xmvn-generator
#Requires:       (ant-openjdk21 if ant)
#Requires:       javapackages-common = %{version}-%{release}
#Requires:       xmvn-tools
#Requires:       java-25-openjdk-devel
#Requires:       xmvn-generator
#Requires:       (ant-openjdk25 if ant)
#Requires:       %{python_prefix}-javapackages = %{version}-%{release}
#Requires:       javapackages-local = %{version}-%{release}
#  ** javapoet/javapoet.spec 31/78**
#BuildRequires: maven-local
#  ** jcip-annotations/jcip-annotations.spec 32/78**
#BuildRequires:  maven-local
#  ** jcuber/jcuber.spec 33/78**
#BuildRequires:  java-devel
#Requires:       java jpackage-utils
#  ** jedit/jedit.spec 34/78**
#Requires:       java >= 1:11
#Requires:       javapackages-filesystem
#  ** jFormatString/jFormatString.spec 35/78**
#BuildRequires:  javapackages-local
#Requires:       java-headless, jpackage-utils
#Requires:       java-javadoc
#  ** jigawatts/jigawatts.spec 36/78**
#BuildRequires: java-devel
#BuildRequires: maven-local
#BuildRequires: maven-surefire
#Requires:   java-headless
#  ** jorbis/jorbis.spec 37/78**
#BuildRequires:  java-devel
#Requires:       java-headless
#Requires:       java
#  ** jpanoramamaker/jpanoramamaker.spec 38/78**
#BuildRequires:  java-devel
#BuildRequires:  ant
#Requires:       java
#  ** jssc/jssc.spec 39/78**
#BuildRequires:	java-devel
#BuildRequires:	javapackages-local
#Requires:	java-headless
#  ** juniversalchardet/juniversalchardet.spec 40/78**
#BuildRequires:  maven-local
#  ** libbase/libbase.spec 41/78**
#BuildRequires: ant, java-devel, jpackage-utils
#Requires: java-headless, jpackage-utils
#  ** libfonts/libfonts.spec 42/78**
#BuildRequires: ant, java-devel, jpackage-utils, libloader >= 1.1.3
#Requires: java-headless, jpackage-utils, libloader >= 1.1.3
#  ** libformula/libformula.spec 43/78**
#BuildRequires: ant, java-devel, jpackage-utils, libbase >= 1.1.3
#Requires: java-headless, jpackage-utils, libbase >= 1.1.3
#  ** liblayout/liblayout.spec 44/78**
#BuildRequires: ant, java-devel, jpackage-utils, flute, libloader
#Requires: java-headless, jpackage-utils, flute, libloader >= 1.1.3
#  ** libloader/libloader.spec 45/78**
#BuildRequires: ant, java-devel, jpackage-utils
#Requires: java-headless, jpackage-utils, libbase >= 1.1.3
#  ** librepository/librepository.spec 46/78**
#BuildRequires: ant, java-devel, jpackage-utils, libbase >= 1.1.3
#Requires: java-headless, jpackage-utils, libbase >= 1.1.3
#  ** libserializer/libserializer.spec 47/78**
#BuildRequires: ant, java-devel, jpackage-utils, libbase >= 1.1.2
#Requires: java-headless, jpackage-utils, libbase >= 1.1.2
#  ** libvirt-java/libvirt-java.spec 48/78**
#Requires:   java-headless >= 1.5.0
#Requires:   java >= 1.5.0
#BuildRequires:  ant
#BuildRequires:  java-devel >= 1.5.0
#  ** Mars/Mars.spec 49/78**
#BuildRequires:  ant
#BuildRequires:  java-devel
#Requires:       java
#  ** mecab-java/mecab-java.spec 50/78**
#BuildRequires:	java-%2-openjdk-devel \
#BuildRequires:	javapackages-local-openjdk%2 \
#BuildRequires:	javapackages-tools
#Requires:	java-headless
#  ** miglayout/miglayout.spec 51/78**
#BuildRequires:  java-devel
#Requires:       java
#  ** mp/mp.spec 52/78**
#BuildRequires: java-devel
#  ** mysql-connector-java/mysql-connector-java.spec 53/78**
#BuildRequires:  javapackages-local-openjdk21
#BuildRequires:  javassist
#BuildRequires:  protobuf-java
#  ** octave/octave.spec 54/78**
#BuildRequires:  java-devel
#BuildRequires:  javapackages-local
#Requires:       java-headless
#  ** openjdk-asmtools/openjdk-asmtools.spec 55/78**
#BuildRequires:  (java-17-openjdk-devel or java-21-openjdk-devel or java-latest-openjdk-devel)
#BuildRequires:  maven-local
#Requires:  (java-17-headless or java-21-openjdk-headless or java-latest-openjdk-headless)
#Requires:       javapackages-tools
#  ** openjfx/openjfx.spec 56/78**
#Requires:       java-headless
#BuildRequires:  javapackages-tools
#BuildRequires:  java-devel
#BuildRequires:  maven-local
#BuildRequires:  ant
#  ** OpenStego/OpenStego.spec 57/78**
#BuildRequires:  java-devel
#BuildRequires:  ant
#Requires:       java-headless
#  ** parserng/parserng.spec 58/78**
#BuildRequires: maven-local
#BuildRequires: maven-surefire
#BuildRequires: java-devel
#Requires: java-headless
#  ** pdftk-java/pdftk-java.spec 59/78**
#BuildRequires:  ant
#BuildRequires:  javapackages-local
#Requires:       java-headless
#Requires:       javapackages-tools
#  ** pentaho-libxml/pentaho-libxml.spec 60/78**
#BuildRequires: ant, java-devel, jpackage-utils, libbase, libloader
#Requires: java-headless, jpackage-utils, libbase >= 1.1.2, libloader >= 1.1.2
#  ** pentaho-reporting-flow-engine/pentaho-reporting-flow-engine.spec 61/78**
#BuildRequires: ant, java-devel, jpackage-utils, libbase, libserializer
#Requires: java-headless, jpackage-utils, libbase >= 1.1.3, libfonts >= 1.1.3
#  ** plantuml/plantuml.spec 62/78**
#BuildRequires:  ant
#BuildRequires:  javapackages-local
#Requires:       java
#Requires:       javapackages-tools
#  ** procyon/procyon.spec 63/78**
#BuildRequires:  javapackages-tools
#BuildRequires:  java-devel
#Requires:      java-headless
#Requires:      javapackages-tools
#Requires:      javapackages-tools
#Requires:      javapackages-tools
#Requires:      javapackages-tools
#Requires:      javapackages-tools
#Requires:      javapackages-tools
#  ** regexp/regexp.spec 64/78**
#BuildRequires:  javapackages-local-openjdk25
#BuildRequires:  ant
#  ** rhino/rhino.spec 65/78**
#BuildRequires:  maven-local
#Requires:       javapackages-tools
#  ** R-rJava/R-rJava.spec 66/78**
#no hit in R-rJava/R-rJava.spec!!
#  ** rsyntaxtextarea/rsyntaxtextarea.spec 67/78**
#BuildRequires:  java-devel
#BuildRequires:  maven-local
#Requires:       java-headless
#  ** sblim-cim-client2/sblim-cim-client2.spec 68/78**
#BuildRequires:  java-devel >= 1.4
#BuildRequires:  ant >= 0:1.6
#Requires:       java-headless >= 1.4
#  ** sblim-cim-client/sblim-cim-client.spec 69/78**
#BuildRequires:  java-devel >= 1.4
#BuildRequires:  ant >= 0:1.6
#Requires:       java-headless >= 1.4
#  ** sdljava/sdljava.spec 70/78**
#BuildRequires:  javapackages-local
#BuildRequires:  ant
#Requires:       java
#Requires:       javapackages-filesystem
#Requires:       javapackages-tools
#  ** stringtemplate/stringtemplate.spec 71/78**
#BuildRequires: ant
#BuildRequires: ant-antlr
#BuildRequires: javapackages-local
#Requires:       java-javadoc
#  ** swing-layout/swing-layout.spec 72/78**
#BuildRequires:  javapackages-local
#BuildRequires:  java-devel >= 1.3
#BuildRequires:  ant
#Requires:       java-headless >= 1.3
#  ** t-digest/t-digest.spec 73/78**
#BuildRequires:  maven-local
#Requires:       java
#  ** tomcat/tomcat.spec 74/78**
#BuildRequires: ant
#BuildRequires: java-devel
#BuildRequires: javapackages-local
#Requires: (java-headless >= %{min_java_version} or java >= %{min_java_version})
#  ** vecmath1.2/vecmath1.2.spec 75/78**
#BuildRequires:  java-devel >= 1:1.6.0
#Requires:       java-headless >= 1:1.6.0
#Requires:       javapackages-filesystem
#  ** voms-clients-java/voms-clients-java.spec 76/78**
#BuildRequires:	maven-local
#Requires:	(java-headless or java-11-headless or java-17-headless or java-21-headless)
#Requires:	java-headless
#  ** xmvn-generator/xmvn-generator.spec 77/78**
#BuildRequires:  javapackages-bootstrap
#BuildRequires:  maven-local-openjdk25
#  ** xmvn/xmvn.spec 78/78**
#BuildRequires:  javapackages-bootstrap
#BuildRequires:  maven
#BuildRequires:  maven-local-openjdk25
#BuildRequires:  maven
#Requires:       maven
#Requires:       maven-jdk-binding
#Requires:       maven-lib
#Requires:       maven-resolver
#Requires:       maven-shared-utils
#Requires:       maven-wagon
