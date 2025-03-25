import re
import sys
import subprocess
import argparse
from pathlib import Path

def parse_versions_file(versions_path, is_snapshot=False):
    project_keys = {}
    versions = {}
    release_versions = {}
    repos = {}
    directories = []
    current_section = None

    versions_file = Path(versions_path)
    if not versions_file.exists():
        print(f"Error: {versions_path} not found")
        sys.exit(1)

    with versions_file.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip().replace('\r', '')
            if line in ["PROJECT_KEY", "VERSIONS", "RELEASE_VERSIONS", "REPOS", "DIRECTORIES"]:
                current_section = line
                continue
            if not line or current_section is None:
                continue
            if current_section == "PROJECT_KEY" and "=" in line:
                key, val = line.split("=", 1)
                project_keys[key.strip()] = val.strip()
            elif current_section == "VERSIONS" and "=" in line:
                key, val = line.split("=", 1)
                versions[key.strip()] = val.strip()
            elif current_section == "RELEASE_VERSIONS" and "=" in line:
                key, val = line.split("=", 1)
                release_versions[key.strip()] = val.strip()
            elif current_section == "REPOS" and "=" in line:
                key, val = line.split("=", 1)
                repos[key.strip()] = val.strip()
            elif current_section == "DIRECTORIES":
                directories.append(line.strip().strip('"'))
                
    if is_snapshot:
        return project_keys, versions, repos, directories
    else:
        return project_keys, release_versions, repos, directories
    
    

def update_gradle_properties(mod_dir, versions, is_snapshot=False, version_key=None, version_number=None):
    gradle_file = Path(mod_dir) / "gradle.properties"
    if not gradle_file.exists():
        print(f"Error: gradle.properties not found in {mod_dir}")
        sys.exit(1)

    updated_lines = []
    with gradle_file.open("r", encoding="utf-8") as f:
        for line in f:
            if not line.strip().startswith("#"):
                match = re.match(r"^(\w+)=([^\s]+)", line)
                if match:
                    #print("MATCHING LINE: ", line)
                    key, val = match.groups()
                    if key == "mod_version" and version_number:
                        print(f"Updating {key}: {val} --> {version_number}")
                        line = f"{key}={version_number}\n"
                    elif key in versions:
                        print(f"Updating {key}: {val} --> {versions[key]}")
                        line = f"{key}={versions[key]}\n"
            updated_lines.append(line)

    with gradle_file.open("w", encoding="utf-8") as f:
        f.writelines(updated_lines)

def update_dependent_projects(dependent_dirs, version_key, version_number):
    new_version = f"{version_number}"
    for target_dir in dependent_dirs:
        gradle_properties = Path(target_dir) / "gradle.properties"
        if gradle_properties.exists():
            updated_lines = []
            with gradle_properties.open("r", encoding="utf-8") as f:
                for line in f:
                    if not line.strip().startswith("#"):
                        match = re.match(r"^(\w+)=([^\s]+)", line)
                        if match:
                            key, val = match.groups()
                            if key == version_key:
                                print(f"Updating {key} in {target_dir}: {val} --> {new_version}")
                                line = f"{key}={new_version}\n"
                    updated_lines.append(line)
            with gradle_properties.open("w", encoding="utf-8") as f:
                f.writelines(updated_lines)
        else:
            print(f"Warning: gradle.properties not found in {target_dir}. Skipping.")

def run_gradle_tasks(mod_dir, is_snapshot=False):
    mod_path = Path(mod_dir).resolve()
    if not mod_path.exists():
        print(f"Error: Directory {mod_dir} does not exist")
        sys.exit(1)

    gradlew_name = "gradlew.bat" if sys.platform.startswith("win") else "./gradlew"
    gradlew_path = mod_path / gradlew_name

    if not gradlew_path.exists():
        print(f"Error: Gradle wrapper not found at {gradlew_path}")
        sys.exit(1)

    cmds = [[str(gradlew_path), "publishToMavenLocal"]]
    #if not is_snapshot:
        #cmds.append([str(gradlew_path), "publishAllPublicationsToFlatDirReleaseRepository"])

    for cmd in cmds:
        print(f"RUNNING: {' '.join(cmd)}")
        try:
            result = subprocess.run(
                cmd,
                cwd=str(mod_path),
                shell=sys.platform.startswith("win"),
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                sys.exit(result.returncode)
            else:
                print(f"Output: {result.stdout}")
        except subprocess.SubprocessError as e:
            sys.exit(1)

def open_editor(mod_dir):
    gradle_path = Path(mod_dir) / "gradle.properties"
    try:
        if sys.platform.startswith("win"):
            subprocess.run(["notepad.exe", str(gradle_path)], check=True)
            while True:
                response = input("Continue with Gradle tasks? (y/n): ").strip().lower()
                if response == 'y':
                    break
                elif response == 'n':
                    print("Aborting Gradle tasks.")
                    sys.exit(0)
                else:
                    print("Please enter 'y' to continue or 'n' to abort.")
        
    except Exception as e:
        print(f"Warning: could not open editor automatically: {e}")
        input("Manually edit gradle.properties, then press Enter to continue...")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update mod versions for release or SNAPSHOT.")
    parser.add_argument("mod_directory", help="Directory of the mod project")
    parser.add_argument("--version_key", help="Version key for SNAPSHOT update (e.g., orecluster_version)")
    parser.add_argument("--version_number", help="Version number for SNAPSHOT update (e.g., 1.1.0)")
    parser.add_argument("--release", action="store_true", help="Perform a release")
    args = parser.parse_args()

    mod_directory = args.mod_directory
    is_snapshot = not args.release
    
    print(f"Is snapshot: {is_snapshot}")

    if is_snapshot and (not args.version_key or not args.version_number):
        print("Error: --version_key and --version_number are required for SNAPSHOT updates")
        print("Usage: python release_update.py <mod_directory> --snapshot --version_key <key> --version_number <num>")
        sys.exit(1)

    project_keys, release_versions, repos, directories = parse_versions_file("versions.txt", is_snapshot)

    # Determine version_key for the main project if not provided
    version_key = args.version_key
    if not version_key:
        for proj_key, val in project_keys.items():
            if proj_key == mod_directory or val == mod_directory.split('/')[-1]:
                version_key = f"{val.lower()}_version"
                break
        if not version_key:
            print(f"Error: Could not infer version_key for {mod_directory}")
            sys.exit(1)

    # Update main project
    update_gradle_properties(mod_directory, release_versions, is_snapshot, version_key, args.version_number)
    print(f"Updated gradle.properties for {mod_directory}")
    open_editor(mod_directory)

    if is_snapshot:
        maven_repo = Path.home() / ".m2" / "repository" / repos.get(mod_directory, "")
        if maven_repo.exists():
            print(f"Removing {maven_repo}")
            subprocess.run(["rmdir", "/s", "/q", str(maven_repo)], shell=True, check=False)

        # Update dependent projects
        update_dependent_projects(directories, version_key, args.version_number)


    run_gradle_tasks(mod_directory, is_snapshot)