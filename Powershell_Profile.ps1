# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Load Windows Forms assembly
    Add-Type -AssemblyName System.Windows.Forms
    
    # Create message box
    $msgBoxInput = [System.Windows.Forms.MessageBox]::Show("This script must be run as an Administrator! Do you want to run it as an Administrator?", "Run as Administrator", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($msgBoxInput -eq "Yes") {
        # Relaunch as an admin
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } else {
        Write-Host "Sorry, can't run without privileges. Bye!" -ForegroundColor Red
	  sleep 5
        exit
    }
}




echo " "
echo "                                  ___    __        "
echo "                       ____  _  _<  /___/ /__      "
echo "                      / __ \| |/_/ / __  / _ \     "
echo "                     / /_/ />  </ / /_/ /  __/     "
echo "                     \____/_/|_/_/\__,_/\___/     "

echo " "

Write-Host "[PS1nstaller]" -ForegroundColor DarkGreen

Write-Host "[Version 2.3]" -ForegroundColor DarkRed

echo " Wait till Process Start..."


sleep 5




# Running as admin from here
Write-Host "[10%  ][Checking execution policy]" -ForegroundColor Cyan
$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($executionPolicy -ne 'RemoteSigned') {
    Write-Host "[SETTING][Setting execution policy to RemoteSigned]" -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force 2>&1 | Out-Null
} else {
    Write-Host "[SKIP ][Execution policy is already set to RemoteSigned. Moving to next.]" -ForegroundColor Yellow
}

Write-Host "[20%  ][Installing Scoop]" -ForegroundColor Cyan
if (Test-Path ~\scoop) {
    Write-Host "[SKIP ][Scoop is already installed. Moving to next.]" -ForegroundColor Yellow
} else {
    Write-Host "[INSTALLING][Downloading Scoop...]" -ForegroundColor Yellow
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
}

echo "Installing Git"

scoop install git

echo "Done"

sleep 2

Write-Host "[30%  ][Adding extras bucket]" -ForegroundColor Cyan
scoop bucket add extras

echo "Done"

sleep 2

Write-Host "[40%  ][Installing Meow]" -ForegroundColor Cyan
scoop install meow

echo "Done"

sleep 2

Write-Host "[60%  ][Updating Meow]" -ForegroundColor Cyan
scoop update meow

echo "Done"

sleep 2


Write-Host "[70%  ][Installing Terminal-Icons]" -ForegroundColor Cyan
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Write-Host "[SKIP ][Terminal-Icons is already installed. Moving to next.]" -ForegroundColor Yellow
} else {
    Write-Host "[INSTALLING][Installing Terminal-Icons...]" -ForegroundColor Yellow
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force
}

Write-Host "[80%  ][Installing/Updating OhMyPosh]" -ForegroundColor Cyan
$upgradeOutput = winget install JanDeDobbeleer.OhMyPosh -NoOutput 2>&1
if ($upgradeOutput -notlike "*No applicable upgrade found.*") {
    Write-Host "[UPGRADE ][OhMyPosh successfully upgraded. Moving to next.]" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP ][No applicable upgrade found. Moving to next.]" -ForegroundColor Yellow
}

$directoryPath = "C:\Temp"

if (!(Test-Path $directoryPath)) {
    Write-Host "[CREATING][Creating Temp folder in C:...]" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $directoryPath | Out-Null
    Write-Host "[DONE ][Temp folder created successfully.]" -ForegroundColor Green
} else {
    Write-Host "[SKIP ][Temp folder already exists. Moving to next process...]" -ForegroundColor Yellow
}


Write-Host "[90%  ][Downloading PowerShell profile files]" -ForegroundColor Cyan

# Download the file from GitHub
$source = "https://github.com/Ox1de-crypto/powerhell_x1/archive/refs/heads/main.zip"
$destination = "C:\Temp\PowerShellProfile.zip"

Invoke-WebRequest $source -OutFile $destination

# Unzip the downloaded file
Expand-Archive -Path $destination -DestinationPath "C:\Temp\PowerShellProfile" -Force

Write-Host "[95%  ][Moving files to Windows PowerShell directory]" -ForegroundColor Cyan

# Fetching username
$username = [Environment]::UserName

# Setting up the directory path
$directoryPath = "C:\Users\$username\Documents\WindowsPowerShell"

# Check and Create directory if it does not exist
if (!(Test-Path $directoryPath)) {
    Write-Host "[CREATING][Creating WindowsPowerShell folder...]" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $directoryPath | Out-Null
} else {
    Write-Host "[SKIP ][WindowsPowerShell directory already exists. Moving to next.]" -ForegroundColor Yellow
}

# Move the files to the directory
Get-ChildItem "C:\Temp\PowerShellProfile\powerhell_x1-main\*" | ForEach-Object {
    $destinationFile = Join-Path -Path $directoryPath -ChildPath $_.Name
    if (!(Test-Path $destinationFile)) {
        Write-Host "[MOVING][Moving file $($_.Name) to WindowsPowerShell directory...]" -ForegroundColor Yellow
        Copy-Item -Path $_.FullName -Destination $directoryPath
    } else {
        Write-Host "[SKIP ][File $($_.Name) already exists in the WindowsPowerShell directory. Moving to next.]" -ForegroundColor Yellow
    }
}

echo " "
echo " "
echo " Attempting to installig the Nerd Font"
echo " " 
echo " "
Write-Host "[ATTENTION!!! Nerd font need to be  Install and change manually]" -ForegroundColor Red
echo " "
sleep 10 
echo " "

# Prepare directory for downloaded fonts on the desktop
$dest = "$env:USERPROFILE\Desktop\Downloaded_Fonts"
if (!(Test-Path -Path $dest)) {
    New-Item -ItemType Directory -Path $dest | Out-Null
}

# Download font files and save them to temporary location
$fontURLs = "https://bit.ly/cascadiafontdownload", "https://bit.ly/jetnerdfontdownload"
foreach ($fontURL in $fontURLs) {
    $fontZipFile = "$env:TEMP\font.zip"
    Invoke-WebRequest -Uri $fontURL -OutFile $fontZipFile

    # Extract font files to temporary location
    $fontTempDir = "$env:TEMP\Font_Files"
    Expand-Archive -Path $fontZipFile -DestinationPath $fontTempDir -Force

    # Move font files to the directory on the desktop, excluding unwanted files
    Get-ChildItem -Path $fontTempDir -Recurse -Exclude LICENSE, readme.md, OFL.txt |
        Move-Item -Destination $dest -Force
}

Write-Host "Fonts have been downloaded and placed on your Desktop in a folder named 'Downloaded_Fonts'." -ForegroundColor Green



Write-Host "[100% ][All tasks completed successfully]" -ForegroundColor Cyan

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("ALL TASKS COMPLETED SUCCESSFULLY!")

