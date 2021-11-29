package org.judovana.fedorajdkbump.builds;

public class Build {
    private final Long buildId;
    private final String pkg;
    private final String vr;
    private final BuildStatus status;
    private final long secondsAgo;
    private final long tookSeconds;

    public Build(Long buildId, String pkg, String vr, BuildStatus status, long secondsAgo, long tookSeconds) {
        this.buildId = buildId;
        this.pkg = pkg;
        this.vr = vr;
        this.status = status;
        this.secondsAgo = secondsAgo;
        this.tookSeconds = tookSeconds;
    }

    public Long getBuildId() {
        return buildId;
    }

    public String getPkg() {
        return pkg;
    }

    public String getVr() {
        return vr;
    }

    public BuildStatus getStatus() {
        return status;
    }

    public long getSecondsAgo() {
        return secondsAgo;
    }

    public long getTookSeconds() {
        return tookSeconds;
    }

    @Override
    public String toString() {
        return "Build{" +
                "buildId=" + buildId +
                ", status=" + status +
                ", nvr='" + nvr() + '\'' +
                ", secondsAgo=" + secondsAgo +
                ", tookSeconds=" + tookSeconds +
                '}';
    }

    private String nvr() {
        if (srpmPassed()) {
            return pkg + "-" + vr;
        } else {
            return "error";
        }
    }

    public  boolean srpmPassed() {
        if (vr.equals("-")) {
            return false;
        } else {
            return true;
        }
    }

    public boolean isQuick() {
        return tookSeconds < 60;
    }
}

