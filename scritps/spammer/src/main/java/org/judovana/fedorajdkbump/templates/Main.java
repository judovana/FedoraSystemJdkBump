package org.judovana.fedorajdkbump.templates;

import org.judovana.fedorajdkbump.builds.BuildsDb;
import org.judovana.fedorajdkbump.people.PeopleDb;

import java.io.File;
import java.io.IOException;

public class Main {

    public static void main(String... args) throws IOException {
        BuildsDb builds = new BuildsDb(new File("./exemplarResults/coprBuildTable.jbump"));
        PeopleDb people = new PeopleDb(new File("../fillCopr/exemplarResults//maintainers.jbump"));
        if (args.length == 0) {
            TemplateLoader t1 = new TemplateLoader(new File("src/main/resources/devel@lists.fedoraproject.org"), builds, people, null);
            System.out.println(t1.getTemplate());
        } else {
            String exemplarAuthor = args[0];
            TemplateLoader t1 = new TemplateLoader(new File("src/main/resources/maintainer@fedoraproject.org"), builds, people, exemplarAuthor);
            System.out.println(t1.getTemplate());
        }
    }
}
