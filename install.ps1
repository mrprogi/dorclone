﻿# Define the path to the params.conf file (replace with actual path)
$ParamsConfFilePath = ".\params.conf"

# Function to read parameters from params.conf file (improved error handling)
function ReadParamsConf {
  param (
    [string]$ParamsConfFilePath
  )
  $params = @{}
  try {
    Get-Content $ParamsConfFilePath | ForEach-Object {
      if (-not $_.StartsWith('#')) {
          $key, $value = $_ -split "=", 2
          $params[$key] = $value
      }
    }
  } catch {
    Write-Error "Error reading params.conf: ($_.Exception.Message)"
    Exit-PSSession
  }
  return $params
}

# Function to install rclone (placeholder for actual download logic)
function InstallRclone {
  param (
    [hashtable]$Params
  )

  Write-Output "Downloading rclone..."

  try {
    Invoke-WebRequest -Uri $Params.RcloneDownloadUrl -OutFile ".\rclone.zip"
    Write-Output "Downloaded file: $($Params.RcloneDownloadUrl)"
    Expand-Archive -Path ".\rclone.zip" -DestinationPath ".\rclone" -Force
    Write-Output "Unzipped rclone.zip to .\rclone"
    Remove-Item -Path ".\rclone.zip"
  } catch {
    Write-Error "Error downloading file: ($_.Exception.Message)"
    Exit-PSSession
  }

  Write-Output "rclone downloaded successfully."
}

# Function to install 7-Zip (placeholder for actual download logic)
function Install7Zip {
  param (
    [hashtable]$Params
  )

  Write-Output "Downloading 7-Zip..."

  try {
    Invoke-WebRequest -Uri $Params.SevenZipDownloadUrl -OutFile ".\7z.exe"
    Write-Output "Downloaded file: $($Params.SevenZipDownloadUrl)"
    Start-Process -FilePath ".\7z.exe" -ArgumentList "/S" -Wait
    Write-Output "Installed 7-Zip"
  } catch {
    Write-Error "Error downloading file: ($_.Exception.Message)"
    Exit-PSSession
  }

  Write-Output "7-Zip downloaded successfully."
}

# Main function to run the installer
function RunInstaller {
  # Read parameters from params.conf files
  $Params = ReadParamsConf -ParamsConfFilePath $ParamsConfFilePath
  Write-Output "Used parameters" $Params

  # Install rClone if it doesn't exist
  if (-not (Test-Path .\rclone)) {
    InstallRclone -Params $Params
  }

  # Install 7-Zip if it doesn't exist
  if (-not (Test-Path .\7z.exe)) {
    Install7Zip -Params $Params
  }

  Copy-Item .\rclone.conf $Params.RcloneBinaryPath -Force

  Write-Output "Installation completed successfully."
}

# Run the installer
RunInstaller
