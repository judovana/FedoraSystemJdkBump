package org.judovana.fedorajdkbump.people;

import org.judovana.fedorajdkbump.builds.BuildsDb;

import java.io.File;
import java.io.IOException;

public class Main {

    public static void main(String... arg) throws IOException {
        PeopleDb people = new PeopleDb(new File("../fillCopr/exemplarResults//maintainers.jbump"));
        System.out.println(people.toString());
    }
}
