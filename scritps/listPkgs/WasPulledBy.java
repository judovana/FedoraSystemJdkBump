import com.sun.jdi.Value;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class WasPulledBy {

    private static HashMap<String, List<String>> keyIsRequiredBy = new HashMap();
    private static HashMap<String, List<String>> keyRequiresVal = new HashMap();

    public static void main(String... args) throws IOException {
        String dbs=System.getenv("DBS");
        if (dbs == null || dbs.trim().isEmpty()) {
            System.err.println("Set $DBS to space separated lsit of dirs withedges. Set NWDBS if you do not want to merge them (slower). Using some weird default");
			dbs="/home/jvanek/git/FedoraSystemJdkBump/scritps/listPkgs/edges/edges";
        }
        String nwdbs =System.getenv("NWDBS");
        if (nwdbs == null){
            for(String s: dbs.split("\\s+")) {
                 readDb(new File(s));
            }
            mainRun(args);
        } else {
           for(String s: dbs.split("\\s+")) {
                 keyIsRequiredBy = new HashMap();
                 keyRequiresVal = new HashMap();
                 readDb(new File(s));
                 mainRun(args);
            }
        }
    }

    private static void mainRun(String[] args) throws IOException {
        if (args.length == 0) {
            try (BufferedReader br = new BufferedReader(new InputStreamReader(System.in))) {
                readPkgsFromStream(br);
            }
        }
        for (String fileOrPkg : args) {
            processCmdLineItem(fileOrPkg);
        }
    }

    private static void readPkgsFromStream(BufferedReader br) throws IOException {
        while (true) {
            String s = br.readLine();
            if (s == null) {
                break;
            }
            processPkg(s);
        }
    }

    private static void processCmdLineItem(String fileUrlPkg) throws IOException {
        if (fileUrlPkg.contains("://")) {
            URL u = new URL(fileUrlPkg);
            try (BufferedReader br = new BufferedReader(new InputStreamReader(u.openStream()))) {
                readPkgsFromStream(br);
            }
        } else {
            if (new File(fileUrlPkg).exists()) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(new File(fileUrlPkg))))) {
                    readPkgsFromStream(br);
                }
            } else {
                processPkg(fileUrlPkg);
            }
        }
    }

    private static void readDb(File dir) {
        System.err.println("Scanning: " + dir.getAbsolutePath());
        //dir with thousands of .X~is~req~by~Y. files
        String[] edges = dir.list();
        for (String edge : edges) {
//            if (edge.contains("nss")) {
//                System.err.println(edge);
//            }
            String[] aBYb = edge.split("~is~req~by~");
            operate(aBYb[0], aBYb[1], keyIsRequiredBy);
            operate(aBYb[1], aBYb[0], keyRequiresVal);
        }
    }

    private static void operate(String key, String val, HashMap<String, List<String>> db) {
        List<String> vals = db.get(key);
        if (vals == null) {
            vals = new ArrayList<>();
            db.put(key, vals);
        }
        vals.add(val);
    }

    private static void processPkg(String pkg) {
        System.err.println("processing pkg: " + pkg);
        List<String> buffer = new ArrayList<>();
        Set<String> results = new HashSet<>();
        blah(pkg, buffer, results);
        List<String> rr = new ArrayList(results);
        Collections.sort(rr, new Comparator<String>() {
            @Override
            public int compare(String s, String t1) {
                return s.length() - t1.length();
            }
        });
        int counter = 0;
        for (String s : rr) {
            counter++;
            if (counter > 50) {
                System.out.println("Shown 50 from " + rr.size());
                break;
            }
            System.out.println(s);
        }
    }

    private static void blah(String pkg, List<String> buffer, Set<String> res) {
        if (buffer.size() > 10) {
            return;
        }
        if (containsJava(buffer)) {
            res.add(buffer.stream().collect(Collectors.joining("<-")));
            return;
        }
        buffer.add(pkg);
        //List<String> vals = keyIsRequiredBy.get(pkg);
        List<String> vals = keyRequiresVal.get(pkg);
        if (vals != null) {
            for (String val : vals) {
                blah(val, buffer, res);
            }
        }
        buffer.remove(buffer.size() - 1);
    }

    private static boolean containsJava(List<String> buffer) {
        for (String s : buffer) {
            if (s.startsWith("java-") || s.startsWith("jre*")) {
                return true;
            }
        }
        return false;
    }
}
