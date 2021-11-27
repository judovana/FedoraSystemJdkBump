package org.judovana.fedorajdkbump.builds;

import java.io.File;
import java.io.IOException;

public class Main {

    public static void main(String... arg) throws IOException {
        BuildsDb builds = new BuildsDb(new File("./exemplarResults/coprBuildTable.jbump"));
        System.out.println(builds.toString());
    }
}
