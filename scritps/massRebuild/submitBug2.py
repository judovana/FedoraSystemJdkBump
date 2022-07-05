import bugzilla
import sys
import os

def main(argv):
    if len(argv) == 0:
      print("usage:")
      print(" bugid => only one parameter will print info about the bug you put as argument. Eg: 2083750")
      print("BUGZILLA_API_KEY environment variable contains your buggzill appi token. eg: pCCq.................................1Q7")
      print("pkgname blocekdBugId fileWithDeps")
      quit()

    if 'BUGZILLA_API_KEY' in os.environ:
      apiKey = os.environ['BUGZILLA_API_KEY']
    else:
      print("BUGZILLA_API_KEY environment variable is mandatory")
      quit()
    b = bugzilla.Bugzilla(url="https://bugzilla.redhat.com//rest/", api_key=apiKey)
    if len(argv) == 1:
      # Just getting a bug
      bug = b.getbug(int(argv[0]))
      print(bug.id, bug.status)
      # note mainly blocks: [bzNumber1,...., bzNmberN]
      for x in bug.get_raw_data():
        print("{}: {}".format(x,bug.get_raw_data()[x]))
      print(bug)
      quit()

    if len(argv) != 3:
      print("pkgname and blockedbug and file with deps are the only three args accepted")
      quit()

    package=argv[0];
    blockedBug=argv[1];
    fileWithDeps=argv[2]

    text_file = open(fileWithDeps, "r")
    data = text_file.read()
    text_file.close()
    
    
    summary = "adapt "+package+" to removal of java on i686"

    description = """Dear maintainer, we are going to drop i686 java-openjdk packages in f37 - https://fedoraproject.org/wiki/Changes/Drop_i686_JDKs
Your package (maybe jsut some subpakcage) is transitively affected by this change:

""" +data+"""

This package was selected as one of the most crucial, which when missing, will burn distro down.
Please take care, and adapt  your package to exclude java on i686. For your convenience, there was added macro %{java_arches}, including all arches java is available on,  which you can use to ifarch-out java specific features out in i686 (on non-java arches). Although for plain java package, the change is as simple as https://src.fedoraproject.org/rpms/maven/c/520942645bfd1e4721dacd536a6ccbf80495a8ae?branch=rawhide, you can not use it. The ExclusiveArch: %{java_arches} is not going to work for you, because your package is not simple java application, and also non-java world depends on it (even if you are one of dozen noarchs in this set)
See exemplar PR: https://src.fedoraproject.org/rpms/graphviz/pull-request/9#request_diff
See more details eg in:: https://bugzilla.redhat.com/show_bug.cgi?id=2102298
See why in : https://pagure.io/fesco/issue/2772
Please read carefully proposal: https://fedoraproject.org/wiki/Changes/Drop_i686_JDKs
Please see tracking bug for most up to date informations: https://bugzilla.redhat.com/show_bug.cgi?id=2083750
(note, that direct dependencies are already work in progress - native reported and worked on, noarch ones autoadjusted)

I'm terribly sorry to report this bug so late in f37 lifecycle. If you can, please handle this with priority.
        """
    # Making a bug
    createinfo = b.build_createbug(
      summary = summary,
      blocks = [int(blockedBug)],
      product = 'Fedora',
      version = 'rawhide',
      component = package,
      severity = 'high',
      cc = ['jvanek@redhat.com', 'sgehwolf@redhat.com', 'java-maint-sig@lists.fedoraproject.org', 'pmikova@redhat.com', 'jhuttana@redhat.com', 'zzambers@redhat.com'],
      description = description)
    newbug = b.createbug(createinfo)
    print("  Created new bug %s=%s  " % ("https://bugzilla.redhat.com/show_bug.cgi?id", newbug.id,))

if __name__ == "__main__":
   main(sys.argv[1:])
