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

  Write-Output "Backup started, please wait..."

  $currentDate = Get-Date -Format yyyyMMdd
  $zipFile = ".\backup.$currentDate.zip"
  Compress-Archive -Path $Params.SourceFolder -DestinationPath $zipFile -CompressionLevel Optimal

  $backupCommand = "$($Params.RcloneBinaryPath)\rclone.exe copy -P $($zipFile) dyntellbackups:$($Params.DestinationFolder)"

  Invoke-Expression -Command $backupCommand

  Write-Output "Backup for $($Params.SourceFolder) ended successfully"

  Remove-Item -Path $zipFile

  Start-Sleep -Seconds 8
}

StartBackup