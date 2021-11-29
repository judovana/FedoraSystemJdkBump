package org.judovana.fedorajdkbump.builds;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class Package {
    private final String name;
    private final List<Build> builds = new ArrayList();

    public Package(String name) {
        this.name = name;
    }

    public Build getNewestBuild() {
        return builds.get(0);
    }

    public void add(Build build) {
        builds.add(build);
        builds.sort((b1, b2) -> {
            return (int) (b2.getBuildId() - b1.getBuildId()); //yah, bad, but build ids are close
        });
    }

    public String getName() {
        return name;
    }

    @Override
    public String toString() {
        return "Package{" +
                "name='" + name + '\'' +
                ", builds:\n    " + builds.stream().map(a -> a.toString()).collect(Collectors.joining("\n    ")) +
                '}';
    }
}

