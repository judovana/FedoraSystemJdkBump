package org.judovana.fedorajdkbump.templates;

import org.judovana.fedorajdkbump.builds.BuildsDb;
import org.judovana.fedorajdkbump.people.PeopleDb;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Properties;

public class TemplateLoader {

    private final String template;
    private final Properties staticMacros;
    private final PeopleDb packagers;
    private BuildsDb builds;

    public TemplateLoader(File template, BuildsDb builds, PeopleDb packagers) throws IOException {
        this.builds = builds;
        this.packagers = packagers;
        this.staticMacros = new Properties();
        staticMacros.load(this.getClass().getResourceAsStream("/macros"));
        this.template = process(Files.readString(template.toPath()));
    }

    private String process(String readString) {
        while (true) {
            String orig = readString;
            for (Object o : staticMacros.keySet()) {
                String s = (String) o;
                if (s.contains("_START")) { //todo, only if no failures!
                    readString = readString.replaceAll("(?s)" + s + ".*" + s.replace("_START", "_END"), staticMacros.getProperty(s));
                } else {
                    readString = readString.replace(s, staticMacros.getProperty(s));
                }
            }
            if (builds != null) {
                readString = readString.replace("<TOTAL_ATTEMPT>", builds.totalPackages() + "");
                readString = readString.replace("<TOTAL_FAILED>", builds.totalFailedPackages() + "");
                readString = readString.replace("<TOTAL_OK>", builds.totalPassedPackages() + "");
                readString = readString.replace("<TOTAL_ERROR>", builds.totalErrorPackages() + "");
                readString = readString.replace("<QUICK_FAIL>", builds.totalQuickFailedPackages() + "");
            }
            if (packagers != null) {
                readString = readString.replace("<TOTAL_PACKAGERS>", packagers.getTotalMaintainers() + "");
            }
            if (readString.equals(orig)) {
                break;
            }
        }
        return readString;
    }

    public String getTemplate() {
        return template;
    }

    public static void main(String... args) throws IOException {
        TemplateLoader t1 = new TemplateLoader(new File("src/main/resources/devel@lists.fedoraproject.org"), null, null);
        TemplateLoader t2 = new TemplateLoader(new File("src/main/resources/maintainer@fedoraproject.org"), null, null);
        System.out.println(t1.getTemplate());
        System.out.println(t2.getTemplate());
    }

}
