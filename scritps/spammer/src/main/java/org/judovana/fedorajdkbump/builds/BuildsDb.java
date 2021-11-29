package org.judovana.fedorajdkbump.builds;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class BuildsDb {

    private final Map<String, Package> packagesWithBuilds = new HashMap();

    public BuildsDb(File file) throws IOException {
        try (Stream<String> lines = Files.lines(Paths.get(file.toString()), StandardCharsets.UTF_8)) {
            lines.forEachOrdered(line -> process(line));
        }
    }

    @Override
    public String toString() {
        return "BuildsDb{" +
                "packagesWithBuilds:\n  " + packagesWithBuilds.values().stream().map(a -> a.toString()).collect(Collectors.joining("\n  ")) +
                '}';
    }

    private void process(String line) {
        Build build = createBuild(line);
        if (build != null) {
            Package pkg = packagesWithBuilds.get(build.getPkg());
            if (pkg == null) {
                pkg = new Package(build.getPkg());
                packagesWithBuilds.put(build.getPkg(), pkg);
            }
            pkg.add(build);
        }

    }

    private Build createBuild(String line) {
        if (line.isEmpty()) {
            return null;
        }
        String[] mainTokens = line.split("\\s+");
        Long buildId = mainTokens[0].equals("-") ? null : Long.parseLong(mainTokens[0]);
        String pkg = mainTokens[1];
        String vr = mainTokens[2];
        String status = mainTokens[mainTokens.length - 1];
        String timestamps = line.replaceFirst(buildId + "\\s+" + pkg + "\\s+" + vr + "\\s+", "").replaceFirst("\\s+" + status, "");
        if (!timestamps.contains("ago")) {
            throw new RuntimeException("Invalid timestamp: " + timestamps + " from " + line);
        }
        String[] whenHow = timestamps.split("ago");
        long secondsAgo = toSeconds(whenHow[0].trim());
        long tookSeconds = toSeconds(whenHow[1].trim());
        return new Build(buildId, pkg, vr, BuildStatus.fromString(status), secondsAgo, tookSeconds);

    }

    private long toSeconds(String s) {
        //feel free to add more
        if (s.contains("years")) {
            return 356 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("months")) {
            return 30 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("weeks")) {
            return 7 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("days")) {
            return 1 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("hours")) {
            return 60 * 60 * toAmount(s);
        } else if (s.contains("minutes")) {
            return 60 * toAmount(s);
        } else if (s.contains("seconds")) {
            return toAmount(s);
        } else if (s.contains("year")) {
            return 365 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("month")) {
            return 30 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("week")) {
            return 7 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("day")) {
            return 1 * 24 * 60 * 60 * toAmount(s);
        } else if (s.contains("hour")) {
            return 60 * 60 * toAmount(s);
        } else if (s.contains("minute")) {
            return 60 * toAmount(s);
        } else if (s.contains("second")) {
            return toAmount(s);
        }
        throw new RuntimeException("unknown time in: " + s);
    }

    private int toAmount(String s) {
        String amount = s.split("\\s+")[0];
        if (amount.equals("an") || amount.equals("a")) {
            return 1;
        }
        return Integer.parseInt(amount);
    }

    public Collection<Package> getPackages() {
        return packagesWithBuilds.values();
    }

    public List<Package> getFailedPackages() {
        return getPackages().stream().filter(a->a.getNewestBuild().getStatus()!=BuildStatus.succeeded).collect(Collectors.toList());
    }

    public List<Package> getQuickFailedPackages() {
        return getFailedPackages().stream().filter(a->a.getNewestBuild().isQuick()).collect(Collectors.toList());
    }

    public List<Package> getPassedPackages() {
        return getPackages().stream().filter(a->a.getNewestBuild().getStatus()==BuildStatus.succeeded).collect(Collectors.toList());
    }

    public List<Package> getErrorPackages() {
        return getPackages().stream().filter(a->!a.getNewestBuild().srpmPassed()).collect(Collectors.toList());
    }

    public int totalErrorPackages() {
        return getErrorPackages().size();
    }
    public int totalPassedPackages() {
        return getPassedPackages().size();
    }

    public int totalFailedPackages() {
        return getFailedPackages().size();
    }

    public int totalQuickFailedPackages() {
        return getQuickFailedPackages().size();
    }

    public int totalPackages() {
        return getPackages().size();
    }
}
