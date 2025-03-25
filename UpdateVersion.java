import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.*;

public class UpdateVersion {

    public static void main(String[] args) throws IOException, InterruptedException {
        if (args.length < 1) {
            System.out.println("Usage: java UpdateVersion <project_name>");
            return;
        }

        String projectName = args[0];
        Path versionsFile = Paths.get("versions.txt");
		boolean isRelease =  (args.length > 1 && args[1].equals("r"));

        // Maps to store project updates and versions
        Map<String, String> projectKey = new HashMap<>();
        Map<String, String> versions = new HashMap<>();
		Map<String, String> repos = new HashMap<>();
        List<String> directories = new ArrayList<>();

        // Read the file and populate maps/lists
        List<String> lines = Files.readAllLines(versionsFile);

        boolean readingProjectKey = false;
        boolean readingVersions = false;
        boolean readingDirectories = false;
        boolean readingRepos = false;
		boolean readingReleaseVersions = false;

        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty()) continue;

            if (line.equals("PROJECT_KEY")) {
                readingProjectKey = true;
				readingReleaseVersions = false;
                readingVersions = false;
                readingDirectories = false;
                readingRepos = false;
            } else if (line.equals("VERSIONS")) {
                readingVersions = true;
				readingReleaseVersions = false;
                readingProjectKey = false;
                readingDirectories = false;
                readingRepos = false;
            } else if (line.equals("RELEASE_VERSIONS")) {
                readingVersions = false;
				readingReleaseVersions = true;
                readingProjectKey = false;
                readingDirectories = false;
                readingRepos = false;
            } else if (line.equals("DIRECTORIES")) {
                readingDirectories = true;
				readingReleaseVersions = false;
                readingProjectKey = false;
                readingVersions = false;
                readingRepos = false;
            }  else if (line.equals("REPOS")) {
                readingRepos = true;
				readingReleaseVersions = false;
                readingDirectories = false;
                readingProjectKey = false;
                readingVersions = false;
            } else if (readingProjectKey) {
                String[] parts = line.split("=");
                if (parts.length == 2) {
                    projectKey.put(parts[0], parts[1]);
                }
            } else if (readingVersions && !isRelease) {
                String[] parts = line.split("=");
                if (parts.length == 2) {
                    versions.put(parts[0], parts[1]);
                }
            } else if (readingReleaseVersions && isRelease) {
                String[] parts = line.split("=");
                if (parts.length == 2) {
                    versions.put(parts[0], parts[1]);
                }
            } else if (readingDirectories) {
                directories.add(line.replace("\"", ""));
            }
            else if (readingRepos) {
                String[] parts = line.split("=");
                if (parts.length == 2) {
                    repos.put(parts[0], parts[1]);
                }
            }
        }

        // Validate the project name
        if (!projectKey.containsKey(projectName)) {
            System.out.println("Error: Project '" + projectName + "' not found in PROJECT_UPDATES.");
            return;
        }
		
		
        // Get the update script and version
        String updateScript = "updateVersions.sh";
        String versionKey = projectKey.get(projectName).toLowerCase().replace("-", "_") + "_version";
        String version = versions.getOrDefault(versionKey, "unknown");
        String repo = repos.getOrDefault(projectName, "unknown");
		
		System.out.println("Version_key: " + versionKey);
		System.out.println("Version: " + version);
		
		
		// Release update mode: just call Python script
		String pythonScript = "updateRelease.py";
		
		// Build the command
        List<String> command = new ArrayList<>();
        command.add("python");  // e.g., "C:\\Python39\\python.exe"
        command.add(pythonScript);  // e.g., "C:\\path\\to\\release_update.py"
        command.add(projectName); // e.g., "MCM_001_HBs-Ore-Cluster-and-Regen"
		
        command.add("--version_key");
		command.add(versionKey);     // e.g., "orecluster_version"
		command.add("--version_number");
		command.add(version);  // e.g., "1.1.0"

        if (isRelease) {
            command.add("--release");
        }
		
		System.out.println("Running release script: " + command.toString());
		
		ProcessBuilder pb = new ProcessBuilder(command);
		pb.inheritIO();
		Process process = pb.start();
		int exitCode = process.waitFor();

		if (exitCode == 0) {
			System.out.println("Release update completed successfully.");
		} else {
			System.out.println("Release update failed with exit code: " + exitCode);
		}
		

    }
}
