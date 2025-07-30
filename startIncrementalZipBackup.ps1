# Define the path to the params.conf file (replace with actual path)
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

# Function to extract the number from MaxAge (e.g., "24h" -> 24)
function ExtractNumberFromMaxAge {
  param (
      [string]$maxAge
  )
  if ($maxAge -match '(\d+)') {
      return [int]$matches[1]
  } else {
      Write-Error "Invalid MaxAge format: $maxAge"
      Exit 1
  }
}

# Function to compress files younger than MaxAge and bigger than 100 MB to a temporary folder
function CompressFiles {
    param (
        [string]$sourceFolder,
        [string]$tempFolder,
        [int]$maxAge
    )

    $cutoffDate = (Get-Date).AddHours(-[int]$maxAge)

    # Ensure the temporary folder exists
    if (-not (Test-Path -Path $tempFolder)) {
        New-Item -Path $tempFolder -ItemType Directory | Out-Null
    }

    Get-ChildItem -Path $sourceFolder | Where-Object {
        ($_.LastWriteTime -ge $cutoffDate)
    } | ForEach-Object {
        $destinationPath = Join-Path -Path $tempFolder -ChildPath ($_.FullName.Replace($sourceFolder, '') + ".zip")
        $destinationDir = Split-Path -Path $destinationPath -Parent
        if (-not (Test-Path -Path $destinationDir)) {
            New-Item -Path $destinationDir -ItemType Directory | Out-Null
        }
        Write-Output "Compressing $($_.FullName) to $destinationPath"
        & .\7z.exe a $destinationPath $_.FullName
    }
}

# Function to start a backup
function StartBackup {

    # Read parameters from params.conf files
    $Params = ReadParamsConf -ParamsConfFilePath $ParamsConfFilePath

    if (-not $Params.MaxAge) {
        Write-Error "Error: Missing mandatory parameter 'MaxAge' in params.conf"
        Exit 1
    }

    if (-not (Test-Path .\7z.exe)) {
        Write-Output "Download the 7-Zip binary running the install.ps1 script"
        Exit 1
    }

    $maxAgeNumber = ExtractNumberFromMaxAge -maxAge $Params.MaxAge
    $tempFolder = ".\BackupTemp"

    CompressFiles -sourceFolder $Params.SourceFolder -tempFolder $tempFolder -maxAge $maxAgeNumber

    $backupCommand = "$($Params.RcloneBinaryPath)\rclone.exe copy -P --max-age $($Params.MaxAge) $tempFolder dyntellbackups:$($Params.DestinationFolder)"
    Write-Output "Executing: $backupCommand"
    Invoke-Expression $backupCommand
    Write-Output "Backup for $($Params.SourceFolder) ended successfully"

    # Cleanup temporary folder after backup
    Remove-Item -Path $tempFolder -Recurse -Force
    
    Start-Sleep -Seconds 5
}

# Start the backup process
StartBackup