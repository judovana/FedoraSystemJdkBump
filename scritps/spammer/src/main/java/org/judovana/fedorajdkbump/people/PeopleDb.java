package org.judovana.fedorajdkbump.people;


import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class PeopleDb {

    private final Map<String, List<String>> maintainersWithPkgs = new HashMap<>();
    private final Map<String, List<String>> pkgsWithMaintainers = new HashMap<>();
    private int mode = 0;

    public PeopleDb(File file) throws IOException {
        try (Stream<String> lines = Files.lines(Paths.get(file.toString()), StandardCharsets.UTF_8)) {
            lines.forEachOrdered(line -> process(line));
        }
    }

    @Override
    public String toString() {
        return "PeopleDb{" +
                "maintainersWithPkgs:\n  " + mapToStr(maintainersWithPkgs) + "\n" +
                "pkgsWithMaintainers:\n  " + mapToStr(pkgsWithMaintainers) +
                '}';
    }

    private static String mapToStr(Map<String, List<String>> map) {
        return map.entrySet().stream().map(a -> a.toString()).collect(Collectors.joining("\n  "));
    }

    private void process(String line) {
        String[] mess = decideLine(line);
        if (mess != null) {
            if (mode == 2) {
                addMaintainerWithPkgs(mess);
            }
            if (mode == 1) {
                addPkgWithMaintainers(mess);
            }
        }

    }

    private static void addArrayToMap(String[] keyAndValues, Map<String, List<String>> map) {
        List<String> list = map.get(keyAndValues[0]);
        if (list == null) {
            list = new ArrayList<>(keyAndValues.length);
            map.put(keyAndValues[0], list);
        } else {
            System.err.println("Warning! adding second times - " + keyAndValues[0]);
        }
        for (int i = 1 /*0 is maintainer*/; i < keyAndValues.length; i++) {
            if (list.contains(keyAndValues[i])) {
                System.err.println("duplicate: " + keyAndValues[i]);
            }
            list.add(keyAndValues[i]);
        }
    }

    private void addPkgWithMaintainers(String[] pkgAndMaintainers) {
        addArrayToMap(pkgAndMaintainers, pkgsWithMaintainers);
    }

    private void addMaintainerWithPkgs(String[] maintainerWithPkgs) {
        addArrayToMap(maintainerWithPkgs, maintainersWithPkgs);
    }

    private String[] decideLine(String line) {
        if (line.isEmpty()) {
            return null;
        }
        if (line.contains("Maintainers by package:")) {
            mode = 1;
            return null;
        }
        if (line.contains("Packages by maintainer:")) {
            mode = 2;
            return null;
        }
        String[] mainTokens = line.split("\\s+");
        return mainTokens;
    }
}
