import java.io.File;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


public class ChangeRequires {

    //this shuold move all jdk21 or unversioned  to jdk25
    private static final Map<String, String> bump21to25Table = new HashMap<>();
    //we expect many packages will fai with jdk25, this should revert them back VERSIONED jdk21
    private static final Map<String, String> rest25to21Table = new HashMap<>();
    //control checksum
    private static final Map<String, Integer> hits = new HashMap<>();

    static {
        bump21to25Table.put("java-headless", "java-25-headless");
        bump21to25Table.put("java", "java-25");
        bump21to25Table.put("java-devel", "java-25-devel");
        bump21to25Table.put("maven-local", "maven-local-openjdk25");
        bump21to25Table.put("maven", "maven-local-openjdk25");
        bump21to25Table.put("mvn", "maven-local-openjdk25");
        bump21to25Table.put("xmvn", "maven-local-openjdk25");
        bump21to25Table.put("ivy-local", "ivy-local, ant-local-openjdk25"); //?
        bump21to25Table.put("ant", "ant-local-openjdk25");
        bump21to25Table.put("ant-local-openjdk21", "ant-local-openjdk25");
        bump21to25Table.put("java-21-openjdk-headless", "java-25-headless");
        bump21to25Table.put("java-21-openjdk", "java-25");
        bump21to25Table.put("java-21-openjdk-devel", "java-25-devel");
        bump21to25Table.put("javapackages-local-openjdk21", "javapackages-local-openjdk25");
        bump21to25Table.put("javapackages-local", "javapackages-local-openjdk25");

        rest25to21Table.put("java-25-headless", "java-21-headless");
        rest25to21Table.put("java-25", "java-21");
        rest25to21Table.put("java-25-devel", "java-21-devel");
        rest25to21Table.put("maven-local-openjdk25", "maven-local-openjdk21");
        rest25to21Table.put("ant-local-openjdk25", "ant-local-openjdk21");
        rest25to21Table.put("java-25-headless", "java-21-headless");
        rest25to21Table.put("java-25", "java-21");
        rest25to21Table.put("java-25-devel", "java-21-devel");
        rest25to21Table.put("javapackages-local-openjdk25", "javapackages-local-openjdk21");
    }

    public static void main(String[] args) throws Exception {
        Map<String, String> table = bump21to25Table;
        if (System.getenv("REVERT") != null) {
            System.out.println("Reverting! 25->21!");
            table = rest25to21Table;

        } else {
            System.out.println("21 or versionless to 25!");
        }
        for (String spec : args) {
            System.out.println("reading "+spec);
            File specFile = new File(spec);
            List<String> lines = Files.readAllLines(specFile.toPath());
            for (int x = 0; x < lines.size(); x++) {
                String line = lines.get(x);
                if (line.startsWith("BuildRequires") || line.startsWith("Requires")) {
                    for (String key : table.keySet()) {
                        String newLine = line;
                        newLine = newLine.replaceAll(" " + key + "$", " " + table.get(key));
                        newLine = newLine.replaceAll("," + key + "$", "," + table.get(key));
                        newLine = newLine.replaceAll(" " + key + "\\s", " " + table.get(key) + " ");
                        newLine = newLine.replaceAll("," + key + "\\s", "," + table.get(key) + " ");
                        newLine = newLine.replaceAll(" " + key + ",", " " + table.get(key) + ",");
                        newLine = newLine.replaceAll("," + key + ",", "," + table.get(key) + ",");
                        newLine = newLine.replaceAll("\t" + key + "$", "\t" + table.get(key));
                        newLine = newLine.replaceAll("\t" + key + "\\s", "\t" + table.get(key) + " ");
                        newLine = newLine.replaceAll("\t" + key + ",", "\t" + table.get(key) + ",");
                        if (!newLine.equals(line)) {
                            line = newLine;
                            lines.set(x, line);
                            Integer counter = hits.get(key);
                            if (counter == null) {
                                counter = 0;
                            }
                            counter++;
                            hits.put(key, counter);
                        }
                    }
                }
            }
            Files.write(specFile.toPath(), lines);
            System.out.println("written "+spec);
        }
        for (String allKey : table.keySet().stream().sorted().toList()) {
            Integer counter = hits.get(allKey);
            if (counter == null) {
                counter = 0;
            }
            System.out.println(allKey + ": " + counter);
        }
    }
}
