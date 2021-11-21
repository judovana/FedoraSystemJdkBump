# FedoraSystemJdkBump
Steps and tools to bump system JDK in Fedora

# pre
* read https://docs.fedoraproject.org/en-US/program_management/changes_policy/
* gather requirements, on how much packages is affected 
  * runetime:
    * ```repoquery -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for runtime```
    * if you have enbled sources in this time, both runtime and build depndecies will be here
  * with enabled source repos then all build time
    *  ```repoquery --arch src -q --whatrequires mvn...java-devel...java-headless...java-... {various subsets} // for build time```
  * eg https://fedoraproject.org/wiki/Changes/Java17#Dependencies
* discusse coopeartion with javapackages-tools
* create proposal
  * eg: https://fedoraproject.org/wiki/Changes/Java17#Other
  * it is always ```[[Category:SystemWideChange]]```
  * at first it is ```[[Category:ChangePageIncomplete]]```, later it is ```[[Category:ChangeReadyForWrangler]]``` and at the end it is  ```[[Category:ChangeAcceptedFxy]]```
    * where xy is of course fedroa verion
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
* Wait for change submitted - eg: https://fedoraproject.org/…690
* Wait for cahge approved - eg: https://fedoraproject.org/…279
* Wait for trackers: https://fedoraproject.org/…847

