# FedoraSystemJdkBump
Steps and tools to bump system JDK in Fedora
1. gather prerequisites, notify lists, write proposal
1. fill fesco and rcm tickets
1. fill copr and run mass rebuild
1. report results and notify maintainers (repeat few times)

# pre
* read https://docs.fedoraproject.org/en-US/program_management/changes_policy/
* write proposal. Eg https://fedoraproject.org/wiki/Changes/Java17 or https://fedoraproject.org/wiki/Changes/Java11
  * target it to exact fedora
* gather requirements, on how much packages is affected 
  * runtime:
    * ```repoquery -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for runtime```
    * if you have enbled sources in this time, both runtime and build depndecies will be here
  * with enabled source repos then all build time
    *  ```repoquery --arch src -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for build time```
  * eg https://fedoraproject.org/wiki/Changes/Java17#Dependencies
  *  You can use: https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/listJavaDependentPkgs.sh
* discusse coopeartion with ***javapackages-tools*** and ***maven***
  * javapackges-tools are usually that simple: https://src.fedoraproject.org/rpms/javapackages-tools/c/637e4be9a46812a99645521530770ce2d10115bd?branch=rawhide
  * maven honor above, but more severe patches, eg: https://src.fedoraproject.org/rpms/javapackages-tools/c/8fe665f78ac8eab03dd57f4936ca379f6ad573bd?branch=rawhide are necessary. But that can be done on the fly ahead of time
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
  * https://bugzilla.redhat.com/show_bug.cgi?id=2024265 - Bug 2024265 - java-17-openjdk as system JDK in F36
* The review, the copr and the fesco should go in semi parallel. If not the fesco aproavls, then at least copr and review. 

# system jdk package
* you have review in progress
* the package in reviw is **not** system jdk, to keep rawhide usable, and prvent brekage if/once package goes to older Fedora (which usually happnes)
* in your fork of java-latest-openjdk/or freshly created java-futureSystemJdkVersion-openjdk (17 this time), create branch, and there set this package to system jdks
## Branches with changed systyem JDK
* future system jdk becoming system JDK:
  *  eg: https://src.fedoraproject.org/rpms/java-11-openjdk/c/0ba272cf2229deadf4c3f27d67dd0295c0515f18?branch=rawhide
  *  It is good to have tracking, bever merged, PR: https://src.fedoraproject.org/rpms/java-latest-openjdk/pull-request/88
* previou system one no longer system JDK:
  * in your fork of current system jdk (11 this time) create a branch,and in that, stop this jdk to be system one
  * eg: https://src.fedoraproject.org/rpms/java-1.8.0-openjdk/c/6b38e01a0e5aea56e80c2115cc839e2582f160e1?branch=rawhide
  *  It is good to have tracking, marged very very late, PR: https://src.fedoraproject.org/rpms/java-11-openjdk/pull-request/138
* Adapt any other necessary packages, so future jdk will indeed become system jdk
  * javapackages-tools and maven: 
    * https://src.fedoraproject.org/rpms/javapackages-tools/pull-request/8
    * https://src.fedoraproject.org/rpms/maven/pull-request/32
    * https://src.fedoraproject.org/rpms/xmvn/pull-request/9
  * **double check** that it is indeed systemjdk and that no other packages need modification to it actually take effect
    * verify java/java-headless/javac and other versionless provides
    * full listing should be readable from spec when chekcing usages of the systemJdk macro
    * verify the packages are actually built by it
    * only then, it have snese to publish the copr

# prepare copr repository
* install copr client
  * ```sudo dnf install copr-cli```
* create copr repo
  * log into https://copr.fedorainfracloud.org/
  * click "new project"
  * use reasonbale description, eg: *This repo serves as initial research for bumping system jdk from jdk11 to jdk17.*
  * it is enough to build only for "fedora-rawhide-x86_64" (single build checkbox selected)
  * if the last fedora was already branched (jdk17 was done for f36, so f35 was already branched) deselect "Follow Fedora branching".  We will be done before "our" release (f36 for jdk17) branches, and we want the repo to continue working on rawhide in all cases.
  * disable  "Mock bootstrap" (No longer remember why, sorry)
  * done
## add the crucial, modified packages, from theirs forks/branches
* See PRs in https://github.com/judovana/FedoraSystemJdkBump#branches-with-changed-systyem-jdk
* manually via gui, one by one
* or via the adapted script of:
  *  enable copr api key (```man  copr-cli``` will tell)
  *  again, see the coleration with PRs in https://github.com/judovana/FedoraSystemJdkBump/blob/main/README.md#branches-with-changed-systyem-jdk
  *  check the content and execute ```addCrucialPackages.sh``` (https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/addCrucialPackages.sh)
    * If you included frok+branch of java-latest-openjdk, with rename to java-XYZ-openjdk and perhaps with move to system JDK
    * then be aware, that this PKG may be imported as java-latest-openjdk, but later a duplciate, java-XYZ-oepnjdk will apear. 
      * Feel free to remove the latest duplicate
  *  **in this prelmiary stage** the packages are from various forks or whereabouts, **later**, after merge, they will bemoved to ones from normal repos
* ensure thsoe built and resulls are correct
* add one your well known package, which you know will be afffected by bump.
  * verify
## add the whole swarm of packages depnding on jdks
### Manual way:
* use https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/listJavaDependentPkgs.sh and https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/nvfrsToNames.sh to find all packages you wish to include in your copr.
* it is recomended to exclude orphans (see also https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/find-package-maintainers)
* it have no sense to process subpkgs or dead packages (see https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/nvfrsToNames.sh)
* **do not include crucial packages**
  * otherwise your custom setup for them will be lost (the https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/addListOfPkgs.sh is handling that by default)
* upload them to your copr one by, by https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/repoToCopr.sh
### Automated way:
* execute https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/addListOfPkgs.sh
  * It expects one parameter, file with list of packages to upload
  * the file must be pkgs only - filter dead.packages and subpakcages before
  * it can use default (https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/listPkgs/exemplarResults/all.jbump)
  * and is filtering out orphans and crucial packages
  * canbe used also to fix/modify the repo(s)

* Once you are done, go to your copr packages tab
  * eg https://copr.fedorainfracloud.org/coprs/jvanek/java17/packages/
  * click rebuild all
  * click build
  * go sleep

## Reporting failures
### devel@lists.fedoraproject.org
* Adapt scritps/spammer/src/main/resources/macros (https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/src/main/resources/macros)
* Double chheck that tempalte scritps/spammer/src/main/resources/devel@lists.fedoraproject.org is sane (https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/src/main/resources/devel@lists.fedoraproject.org)
* in ```scritps/spammer``` (cwd sensitive) run  ```java -cp target/spammer-1.0-jar-with-dependencies.jar org.judovana.fedorajdkbump.templates.Main``` 
  * or from IDE
* That, assuming you refreshed all encessary files, provides you by statistics-full email for devel@lists.fedoraproject.org
  * scritps/spammer/src/main/resources/devel@lists.fedoraproject.org
  * scritps/fillCopr/exemplarResults//maintainers.jbump
  * scritps/spammer/exemplarResults/coprBuildTable.jbump
* send this email to devel@lists.fedoraproject.org
  * eg: https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/thread/KE7EAY6HKXNQV6PPCEAJAYL2MU7IXKHN/
  * **take care of the thread!**
### individual maintainers
* keep the email on devel for a while and watch responses
* once fixing rate drops, spam individual packagers
  * alias **some_packager@fedoraproject.org** is to be used
* If you do not want to write each of aprox 200 maintainers (see https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/exemplarResults/maintainers.jbump) one by one
* use **spam tool**
  * https://github.com/judovana/FedoraSystemJdkBump/tree/main/scritps/spammer
  * now impelmented for OAuth2 gmail.  (read https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/src/main/java/org/judovana/fedorajdkbump/Main.java#L16)
  * it requires 
    * senders emial - eg jvanek@redhat.com
    * token - eg: ya29.a0A...-XYQ
    * template file - https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/src/main/resources/maintainer@fedoraproject.org
    * list of maintainers - https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/exemplarResults/maintainers.jbump
    * statuses of builds - https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/exemplarResults/coprBuildTable.jbump
    * sytem variable of **"DO"**
  * adapt https://github.com/judovana/FedoraSystemJdkBump/commit/ebc049960ca93cefb812267f15e5ee46ec954bb8#diff-b74c70db11edf66327b5141f9620fde367914ef9c1cc33e613b6d3e59dde694aR91
  * adapt template (eg: maintainer@fedoraproject.org)
  * in ```scritps/spammer``` (cwd sensitive) run ```DO="" java -cp target/spammer-1.0-jar-with-dependencies.jar org.judovana.fedorajdkbump.Main
"your@email.com" ya29.gmail...token  "src/main/resources/maintainer@fedoraproject.org"   ../fillCopr/exemplarResults//maintainers.jbump   ./exemplarResults/coprBuildTable.jbump```
    * where DO is empty, *maintainers|regex*, or *true*
    * empty will save all future emails for check. **do this!!!**
    * maintainers|regex will send email only to matching maintainers. **test this on yourself and on your friend or two**
      * gmail is not showing emials to yourself in innbox. They end in its sendbox. See: https://github.com/judovana/FedoraSystemJdkBump/commit/ebc049960ca93cefb812267f15e5ee46ec954bb8#diff-b74c70db11edf66327b5141f9620fde367914ef9c1cc33e613b6d3e59dde694aR72
    * true will send email to all maintainers in given maintainers file      
#### antispam in email providers
* even good hosting can kick yo out after few decades of emails in short timeframe
  * this the sleep here
* Still, if you are kicked out, it is bad idea to spam again the people yo already spammed
  * simply copypaste output of your last spammer run
  * put it to the scritps/spammer/src/main/resources/antispam (eg https://github.com/judovana/FedoraSystemJdkBump/commit/16ad465b2e7712f7f4164953516222c18d1f3ad3)
  * comit, push, rebuild app, wait few minutes
  * run spammer again
### big blame file
* Based on all files above, hardcoded in src, you can generate huge blame file: https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/spammer/exemplarResults/verboseResults.txt
* in ```scritps/spammer``` (cwd sensitive) run ```java -cp target/spammer-1.0-jar-with-dependencies.jar org.judovana.fedorajdkbump.templates.TemplateLoader```
* you may add it to the thread(s) on devel list from time to time

# new main JDK package
* once the review of forked java-latestr-openjdk is finished
  * create branch PR to forked JDK, where it is already main jdk
  * delete PR to java-latest-oepnjdk
  * adjust copr
    * latest from normal rahide
    * forked jdk from systemJdk branch
* here you are nearly done with alfa
  * fix all issues which rise
  * fix as many packages as you can
  * verify that thet desired jdk is still used for builds
  * run few mass rebuilds of copr
  * **keep an eye on those builds**
# weird depndencies pulled into build aka duplicated nvrs
* Copr have one wird function. If you mass rebuild, then you will see several same NVR of package. Unluckily, Copr keeps them all, and if you build, **random** one is selected to satisfy depndencies.
* So it is good idea to remove  old passed builds. That is automated by: https://github.com/judovana/FedoraSystemJdkBump/blob/main/scritps/fillCopr/purgeCopr.sh
* Run it from time to time, especially if you run seveal mass rebuilds, then lets say between each
* we keep failures, as failures are reported to maintainers, so we do not want to lost logs
