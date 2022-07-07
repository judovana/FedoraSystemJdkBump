/*
This is super single usecase class.
It takes directories with deps and parse each pkg<-pkg<... line
the pkgs then have to be passed through other scripts and verified it is not already reported
*/
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
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class MissingDepsFinder {

    private static Set<String> direct = new HashSet();
    private static Set<String> leaves = new HashSet();
    private static Set<String> newCandidates = new HashSet();
    private static Set<String> javas = new HashSet();

    public static void main(String... args) throws IOException {
        mainRun(args);
    }

    private static void mainRun(String[] args) throws IOException {
        for (String dir : args) {
            processCmdLineItem(new File(dir));
        }
       System.out.println("**** direct ****");
       for(String s: direct){
           System.out.println("d " + s);
       }
       System.out.println("**** leaves ****");
       for(String s: leaves){
           System.out.println("l " + s);
       }
       System.out.println("**** javas ****");
       for(String s: javas){
           System.out.println("j " + s);
       }
       System.out.println("**** newCandidates ****");
       for(String s: newCandidates){
           System.out.println("n " + s);
       }
    }



    private static void processCmdLineItem(File dir) throws IOException {
        for (File f: dir.listFiles()) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(f)))) {
                    readPkgsFromStream(br);
            }
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


    private static void processPkg(String pkg) {
	   if (!pkg.contains("<-")){
         return;
       }
       String[] split = pkg.split("<-");
       for(int x=0; x< split.length; x++) {
           if (x == 0 ) {
               leaves.add(split[x]);
           } else if (x == split.length-2){
			   direct.add(split[x]);
           } else if (x == split.length-1){
			   javas.add(split[x]);
           } else {
               newCandidates.add(split[x]);
           }
		}
    }
}
