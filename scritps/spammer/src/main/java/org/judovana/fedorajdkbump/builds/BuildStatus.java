package org.judovana.fedorajdkbump.builds;

import java.util.Arrays;

public enum BuildStatus {
    succeeded, failed, running, aborted;

    public static BuildStatus fromString(String s) {
        return Arrays.stream(BuildStatus.values()).filter(v -> v.toString().equals(s)).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("unknown value: " + s));
    }
}
