# Define the source directory and files
$sourceDirectory = ".\BO1-Reimagined-expanded\"
$filesToCopy = @("BO1-Reimagined-expanded.iwd", "mod.ff")

# Define the local and network destination folders
$localDestination = ".\Reimagined-Expanded\"
$networkDestination = "\\JACKSALLY\Call of Duty Black Ops\mods\Reimagined-Expanded"

# Copy files to local destination
foreach ($file in $filesToCopy) {
    Copy-Item -Path "$sourceDirectory\$file" -Destination $localDestination -Force
}

# Copy files to network destination
foreach ($file in $filesToCopy) {
    Copy-Item -Path "$sourceDirectory\$file" -Destination $networkDestination -Force
}

Write-Output "Files copied successfully."
