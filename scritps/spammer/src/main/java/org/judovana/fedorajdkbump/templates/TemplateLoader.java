package org.judovana.fedorajdkbump.templates;

import org.judovana.fedorajdkbump.builds.BuildsDb;
import org.judovana.fedorajdkbump.builds.Package;
import org.judovana.fedorajdkbump.people.PeopleDb;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Properties;
import java.util.stream.Collectors;

public class TemplateLoader {

    private final String expandedTemplate;
    private final Properties staticMacros;
    private final PeopleDb packagers;
    private final String recipient;
    private BuildsDb builds;

    public TemplateLoader(File template, BuildsDb builds, PeopleDb packagers, String recipient) throws IOException {
        this.recipient = recipient;
        this.builds = builds;
        this.packagers = packagers;
        this.staticMacros = new Properties();
        staticMacros.load(this.getClass().getResourceAsStream("/macros"));
        this.expandedTemplate = process(Files.readString(template.toPath()));
    }

    private String process(String readString) {
        while (true) {
            String orig = readString;
            for (Object o : staticMacros.keySet()) {
                String s = (String) o;
                if (s.contains("_START")) {
                    String endTag = s.replace("_START", "_END");
                    if (recipient != null) {
                        List<String> itsPkgs = packagers.getPkgsOf(recipient);
                        if (builds.totalFailedPackages(Optional.of(itsPkgs)) == 0) {
                            readString = readString.replaceAll("(?s)" + s + ".*" + endTag,
                                    builds.totalPackages(Optional.of(itsPkgs)) == 0 ? "You do not have any packages?" : staticMacros.getProperty(s));

                        } else {
                            readString = readString.replaceAll("(?s)" + s + "\\s+", "").replaceAll("(?s)" + endTag + "\\s+", "");
                        }
                    }
                } else {
                    readString = readString.replace(s, staticMacros.getProperty(s));
                }
            }
            if (builds != null) {
                readString = readString.replace("<TOTAL_ATTEMPT>", builds.totalPackages(Optional.empty()) + "");
                readString = readString.replace("<TOTAL_FAILED>", builds.totalFailedNonBorkedPackages(Optional.empty()) + "");
                readString = readString.replace("<TOTAL_OK>", builds.totalPassedPackages(Optional.empty()) + "");
                readString = readString.replace("<TOTAL_ERROR>", builds.totalErrorPackages(Optional.empty()) + "");
                readString = readString.replace("<QUICK_FAIL>", builds.totalQuickFailedPackages(Optional.empty()) + "");
                readString = readString.replace("<TOTAL_FAILED_AND_ERRORED>", builds.totalFailedPackages(Optional.empty()) + "");
            }
            if (packagers != null) {
                readString = readString.replace("<TOTAL_PACKAGERS>", packagers.getTotalMaintainers() + "");
            }
            if (recipient != null) {
                readString = readString.replace("<PACKAGER_NAME>", recipient);
                List<String> itsPkgs = packagers.getPkgsOf(recipient);
                List<String> allFound = builds.getPackages(Optional.of(itsPkgs)).stream().map(Package::getName).sorted().collect(Collectors.toList());
                List<String> passed = builds.getPassedPackages(Optional.of(itsPkgs)).stream().map(Package::getName).sorted().collect(Collectors.toList());
                List<String> borked = builds.getErrorPackages(Optional.of(itsPkgs)).stream().map(Package::getName).sorted().collect(Collectors.toList());
                List<String> failed = builds.getFailedNonBorked(Optional.of(itsPkgs)).stream().map(Package::getName).sorted().collect(Collectors.toList());
                List<String> quickfailed = builds.getQuickFailedPackages(Optional.of(itsPkgs)).stream().map(Package::getName).sorted().collect(Collectors.toList());
                List<String> slowFail = dist(failed, quickfailed);
                List<String> missing = dist(itsPkgs, allFound);
                readString = readString.replace("<ITS_PKG_COUNT>", allFound.size()+ "");
                readString = readString.replace("<ITS_PKGS_LIST>", nonEmpty(allFound.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<ITS_PASSED>", passed.size()+ "");
                readString = readString.replace("<ITS_PASSED_LIST>", nonEmpty(passed.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<ITS_BORKED>", borked.size() + "");
                readString = readString.replace("<ITS_BORKED_LIST>", nonEmpty(borked.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<ITS_FAILED>", failed.size() + "");
                readString = readString.replace("<ITS_FAILED_LIST>", nonEmpty(failed.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<ITS_QUICK>", quickfailed.size() + "");
                readString = readString.replace("<ITS_QUICK_LIST>", nonEmpty(quickfailed.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<ITS_FAILED_SLOW_LIST>", slowFail.stream().collect(Collectors.joining(", ")));
                readString = readString.replace("<ITS_MISSING>", missing.size() + "");
                readString = readString.replace("<ITS_MISSING_LIST>", nonEmpty(missing.stream().collect(Collectors.joining(", "))));
                readString = readString.replace("<LATEST_STATUSES_WITH_LOGS>", getLogs(builds.getFailedNonBorked(Optional.of(itsPkgs))));
            }

            if (readString.equals(orig)) {
                break;
            }
        }
        return readString;
    }

    private String nonEmpty(String collect) {
        if (collect.trim().isEmpty()){
            return "N/A";
        } else {
            return collect;
        }
    }

    private String getLogs(List<Package> failed) {
        StringBuilder sb = new StringBuilder();
        for (Package pkg : failed) {
            sb.append(pkg.toLink(staticMacros.getProperty("<COPR_ID>"),staticMacros.getProperty("<CHROOT>") )).append("\n");
        }
        return sb.toString();
    }

    private List<String> dist(List<String> all, List<String> some) {
        List<String> r = new ArrayList<>();
        for (String i : all) {
            if (!some.contains(i)) {
                r.add(i);
            }
        }
        return r;
    }

    public String getExpandedTemplate() {
        return expandedTemplate;
    }

    public static void main(String... args) throws IOException {
        TemplateLoader t1 = new TemplateLoader(new File("src/main/resources/devel@lists.fedoraproject.org"), null, null, null);
        TemplateLoader t2 = new TemplateLoader(new File("src/main/resources/maintainer@fedoraproject.org"), null, null, null);
        System.out.println(t1.getExpandedTemplate());
        System.out.println(t2.getExpandedTemplate());
    }

    public String getMacro(String s) {
        return staticMacros.getProperty(s);
    }
}
