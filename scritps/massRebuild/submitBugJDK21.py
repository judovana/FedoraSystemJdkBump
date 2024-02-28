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

    summary = package + " fails to build with java-21-openjdk"
    description = package+""" fails to build with java-21-openjdk as sytem JDK. See https://fedoraproject.org/wiki/Changes/Java21.

For the build logs, see: """+log+"""
We run the rebuild in side tag f41-build-side-84507, but as fail ratio was small, we expect this side tag to be merged into rawhide ASAP.
To reproduce before this date simply: fedpkg clone """+package+"""; cd """+package+""";  fedpkg build --target f41-build-side-84507; #The target is crucial.
After merge, the usual fedpkg build in rawhide should do.

We had tried aprox 400 packages, and aprox 55 had failed, so the java-21-openjdk will be system JDK in f40, and you should fix your package if you want to keep it alive. Usually the fix is simple, and best is to update the package to latest upstream version. Fix the issue in both f40 and rawhide, if possible, the side tag and rebuild of f40 (and bugs) will follow soon.
Let us know here if you have any questions, here in bug, or at java-devel@lists.fedoraproject.org .

We'd appreciate help from the people who know this package best, but if you don't want to work on this now, let us know so we can try to work around it on our side if needed.
        """
    # Making a bug
    createinfo = b.build_createbug(
      summary = summary,
#      short_desc = summary,
#      blocked = 'Java21',
      blocks = [int(parentBug)],
      product = 'Fedora',
      version = 'rawhide',
      component = package,
      severity = 'high',
      cc = ['jvanek@redhat.com', 'java-maint-sig@lists.fedoraproject.org', 'pmikova@redhat.com'],
      description = description)

#    print(description)
    newbug = b.createbug(createinfo)
    print("  Created new bug %s=%s  " % ("https://bugzilla.redhat.com/show_bug.cgi?id", newbug.id,))

if __name__ == "__main__":
   main(sys.argv[1:])
