# FedoraSystemJdkBump
Steps and tools to bump system JDK in Fedora

# pre
* read https://docs.fedoraproject.org/en-US/program_management/changes_policy/
* gather requirements, on how much packages is affected 
  * runtime:
    * ```repoquery -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for runtime```
    * if you have enbled sources in this time, both runtime and build depndecies will be here
  * with enabled source repos then all build time
    *  ```repoquery --arch src -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for build time```
  * eg https://fedoraproject.org/wiki/Changes/Java17#Dependencies
  *  You can use: https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/listJavaDependentPkgs.sh
* discusse coopeartion with ***javapackages-tools*** and ***maven***
* create proposal
  * eg: https://fedoraproject.org/wiki/Changes/Java17#Other
  * it is always ```[[Category:SystemWideChange]]```
  * at first it is ```[[Category:ChangePageIncomplete]]```, later it is ```[[Category:ChangeReadyForWrangler]]``` and at the end it is  ```[[Category:ChangeAcceptedFxy]]```
    * where xy is of course fedora verion
  * do it early, it needs whole future fedora development cycle
    * usual deadline is shortly before branching (so 3 months to finsih it)
  * disucss it in users@lists.fedoraproject.org (brace for weird comment, later it is officially announced in devel@lists.fedoraproject.org)
* fill fesco ticket
  * eg https://pagure.io/fesco/issue/2683
* fill rcm ticket
  * eg https://pagure.io/releng/issue/10364
  * they should be linked together
* discusse it on devel@lists.fedoraproject.org

now time should be taken to Fesco and RCM have spoken, then it is announced by them and work can start

# fesco action
* Wait for change submitted - eg: https://fedoraproject.org/w/index.php?title=Changes%2FJava17&type=revision&diff=630279&oldid=629690
* Wait for cahge approved - eg: https://fedoraproject.org/w/index.php?title=Changes%2FJava17&type=revision&diff=630847&oldid=630279
* Wait for trackers: https://fedoraproject.org/w/index.php?title=Changes%2FJava17&type=revision&diff=630849&oldid=630847

# prepare future system JDK
* Usually you have to fork java-latest-openjdk as java-xy-openjdk as new package. So follow current package review - eg:
  * https://docs.fedoraproject.org/en-US/package-maintainers/Package_Review_Process/
  * and
  * https://bugzilla.redhat.com/show_bug.cgi?id=2024881 - Bug 2024881 - Review Request: java-17-openjdk - The OpenJDK 17 runtime and development environment.
* Your new bug, should block the bug assigned by fesco, eg:
  * https://bugzilla.redhat.com/show_bug.cgi?id=2024265 - Bug 2024265 - java-17-openjdk as system JDK in F36 (edit)
* The review, the copr and the fesco should go in semi parallel. If not the fesco aproavls, then at least copr and review. 

# system jdk package
* you have review in progress
* the package in reviw is usually **not** system jdk, to keep rawhide usable, and prvent brekage if package goes to older Fedora (which usually ahppnes)
* in your fork of java-latest-openjdk/or freshly created java-futureSystemJdkVersion-openjdk (17 this time), create branch, and there set this package to system jdks
  *  eg:
* in your fork of current system jdk (11 this time) create a branch,and in that, stop this jdk to be system one
  * eg:
* Adapt any other necessary packages, so future jdk will indeed become system jdk
  * javapackage-tools: 
  * **double check** that it is indeed systemjdk and that no other packages need modification to it actually take effect
    * verify java/java-headless/javac and other versionless provides
    * full listing should be readable from spec when chekcing usages of the systemJdk macro

# prepare copr repository
* use https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/listJavaDependentPkgs.sh and https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/nvfrsToNames.sh to find all packages you wish to include in your copr
