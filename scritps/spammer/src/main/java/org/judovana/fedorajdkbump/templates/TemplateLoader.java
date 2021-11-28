package org.judovana.fedorajdkbump.templates;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Properties;

public class TemplateLoader {

    private final String template;
    private final Properties staticMacros;

    public TemplateLoader(File template) throws IOException {
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
                    readString = readString.replaceAll("(?s)"+s+".*"+s.replace("_START", "_END"), staticMacros.getProperty(s));
                } else {
                    readString = readString.replace(s, staticMacros.getProperty(s));
                }
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
        TemplateLoader t1 = new TemplateLoader(new File("src/main/resources/devel@lists.fedoraproject.org"));
        TemplateLoader t2 = new TemplateLoader(new File("src/main/resources/maintainer@fedoraproject.org"));
        System.out.println(t1.getTemplate());
        System.out.println(t2.getTemplate());
    }
}
