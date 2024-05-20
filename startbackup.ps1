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

# Function to start a backup
function StartBackup {

  # Read parameters from params.conf files
  $Params = ReadParamsConf -ParamsConfFilePath $ParamsConfFilePath

  if (-not $Params.MaxAge) {
    Write-Error "Error: Missing mandatory parameter 'MaxAge' in params.conf"
    Exit 1
  }

  $backupCommand = "$($Params.RcloneBinaryPath)\rclone.exe copy -P --max-age $($Params.MaxAge) $($Params.SourceFolder) dyntellbackups:$($Params.DestinationFolder)"

  Write-Output "Command: $($backupCommand)"
  Write-Output "Backup started, please wait..."

  Invoke-Expression -Command $backupCommand

  Write-Output "Backup for $($Params.SourceFolder) ended successfully"

  Start-Sleep -Seconds 8
}

StartBackup