package org.judovana.fedorajdkbump.templates;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

public class TemplateLoader {

    private final String template;

    public  TemplateLoader(File template) throws IOException {
        this.template = Files.readString(template.toPath());
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
