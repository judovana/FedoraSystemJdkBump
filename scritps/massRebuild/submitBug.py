import bugzilla
import sys
import os

def main(argv):
    if len(argv) == 0:
      print("usage:")
      print(" bugid => only one parameter will print info about the bug you put as argument. Eg: 1826539")
      print(" package logs [coprUrl] => will submit the FTBFS bug to bugzilla. If you include copr url, aditional paragraph will be included")
      print("BUGZILLA_API_KEY environment variable contains your buggzill appi token. eg: pCCq.................................1Q7")
      print("FEATURE_BUG_ID environment variable contains the bug id of javaX system jdk. eg:2024265")
      quit()

    if 'BUGZILLA_API_KEY' in os.environ:
      apiKey = os.environ['BUGZILLA_API_KEY']
    else:
      print("BZ_API_KEY environment variable is mandatory")
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

    if 'FEATURE_BUG_ID' in os.environ:
      parentBug = os.environ['FEATURE_BUG_ID']
    else:
      print("FEATURE_BUG_ID environment variable is mandatory")
      quit()

    package=argv[0];
    log = argv[1];
    coprUrl = "XX";
    if len(argv) > 2:
      coprUrl= argv[2];

    summary = package + " fails to build with java-17-openjdk"
    if coprUrl != "XX":
      coprPas = """
We had also run the mass rebuilds in copr since November. We keep all encountered failures. See them here: """+coprUrl+"""/package/"""+package+"""
You may find interesting additional informations here. Also we were spamming maintainers regualrly, check you spam folder.
              """
    else:
        coprPas = ""

    description = package+""" fails to build with java-17-openjdk as sytem JDK. See https://fedoraproject.org/wiki/Changes/Java17 .
See especially part about known failures: https://fedoraproject.org/wiki/Changes/Java17#common_issues_packagers_can_face_and_gathered_solutions

For the build logs, see: """+log+"""
We run the rebuild in side tag f36-java17, but as fail ratio was small, we expect this side tag to be merged into rawhide 7 or 8 of February 2022.
To reproduce before this date simply: fedpkg clone """+package+"""; cd """+package+""";  fedpkg build --target f36-java17; #The target is crucial.
After this date the usual fedpkg build in f36 and up should do.

We run two reruns your package failed both.
"""+coprPas+"""

We had tried aprox 500 packages, and aprox 65 had failed, so the java-17-openjdk will be system JDK in f36, and you should fix your package if you want to keep it alive. Usually the fix is simple, and best is to update the package to latest upstream version.
There will be usual mass rebuild once f36 branches. You may got another FTBFS bug.
Let us know here if you have any questions, here in bug, or at java-devel@lists.fedoraproject.org .

We'd appreciate help from the people who know this package best, but if you don't want to work on this now, let us know so we can try to work around it on our side if needed.
        """
    # Making a bug
    createinfo = b.build_createbug(
      summary = summary,
#      short_desc = summary,
#      blocked = 'Java17',
      blocks = [int(parentBug)],
      product = 'Fedora',
      version = 'rawhide',
      component = package,
      severity = 'high',
      cc = ['jvanek@redhat.com', 'sgehwolf@redhat.com', 'java-maint-sig@lists.fedoraproject.org', 'pmikova@redhat.com', 'jhuttana@redhat.com', 'didiksupriadi41@gmail.com'],
      description = description)

#    print(description)
    newbug = b.createbug(createinfo)
    print("  Created new bug %s=%s  " % ("https://bugzilla.redhat.com/show_bug.cgi?id", newbug.id,))

if __name__ == "__main__":
   main(sys.argv[1:])
