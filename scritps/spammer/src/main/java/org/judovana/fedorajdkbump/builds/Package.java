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

    public String toLink(String copr/*jvanek/java17*/, String chroot /*fedora-rawhide-x86_64*/) {
        Build b = getNewestBuild();
        String buildId = preZero(b.getBuildId(),8);//02988253
        return " " + b.getStatus()+ " https://download.copr.fedorainfracloud.org/results/"+copr+"/"+chroot+"/"+buildId+"-"+getName()+"/builder-live.log.gz";
    }

    private String preZero(Long buildId, int i) {
        String s = Long.toString(buildId);
        while (s.length()< i){
            s = "0"+s;
        }
        return s;
    }
}

