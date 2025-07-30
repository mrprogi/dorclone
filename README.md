# Backup System Documentation

This document explains how to use the provided scripts (`startbackup.ps1`, `startIncrementalZipBackup.ps1`, `startZipBackup.ps1`) to automate backups of your desired folder or file to DigitalOcean Spaces using rclone.

## Requirements

- Windows Machine with PowerShell 5.1 or later
- `rclone.conf` configured with your DigitalOcean Spaces access informations. To do so you have to copy the `rclone-temp.conf` file and rename it to *rclone.conf*. Then you have to fill the necesarry informations specified between < ... >. For more information about generating Digital Ocaen Access Keys [click here](https://docs.digitalocean.com/products/spaces/how-to/manage-access/).

## Script Usage

### 1. Configure `params.conf` (essential):

- First you need to copy the `params-temp.conf` file and rename it to *params.conf*.
  
- Update the `RcloneDownloadUrl` with the URL to download the desired *rclone* version (check the *rclone* [website](https://rclone.org/downloads/) for the latest version).
  
- Modify the `RcloneBinaryPath` to reflect the actual location where *rclone* is installed on your system. The path should be like this: `.\rclone\rclone-*version-in-the-folder*`
  
- Set the `MaxAge` to the desired value to only transfer files younger than this parameter.
  
- Ensure the `SourceFolder` path points to the directory containing your files to backup.
  
- Update the `DestinationFolder` with the S3 URI for your DigitalOcean Spaces backup location. For example `dyntellbackups\*client name*`.
  

### 2. Install *rclone* (if needed):

If you don't have *rclone* or *7-Zip* installed into your project's root folder, you can use the `install.ps1` script to download and install it. However, ensure you have downloaded the appropriate and latest version for your Windows architecture (32-bit or 64-bit) from the official *rclone* [website](https://rclone.org/downloads/).

### 3. Run the Backup Script:

#### a.) Copying files directly to Spaces - startbackup.ps1

If all of the configuration are setted appropriatly, simply just **right** click on the *startbackup.ps1* file and click on `Run with PowerShell`.

Or open a PowerShell window and navigate to the directory containing `startbackup.ps1`. Then, execute the script using the following command:

PowerShell

```
.\startbackup.ps1
```

The script will upload the contents of the folder configured in the `SourceFolder` parameter if younger than the value specified in the `MaxAge` parameter.

#### b.) Compressing each files in the source folder and uploading to Spaces - startIncrementalZipBackup.ps1

**Right** click on the *startIncrementalZipBackup.ps1* file and click on `Run with PowerShell`.

The script will compress each files in your chosen directory and upload it to your DigitalOcean Spaces bucket. It will display messages indicating the progress and completion of the backup process.

#### c.) Compressing the source folder and uploading a backup file to Spaces - startZipBackup.ps1

**Right** click on the *startZipBackup.ps1* file and click on `Run with PowerShell`.

The script will compress your chosen directory and upload it to your DigitalOcean Spaces bucket. It will display messages indicating the progress and completion of the backup process.

## Scheduling Backups (Optional)

Here's how you can configure scheduled backups using Task Scheduler in Windows to run your `startbackup.ps1`, `startIncrementalZipBackup.ps1` or `startZipBackup,ps1` script:

**1. Open Task Scheduler:**

- Press the Windows key, search for "Task Scheduler", and open the application.

**2. Create a New Task:**

- Click on "Create Task" in the Actions pane on the right side of the window.

**3. General Tab:**

- Enter a descriptive name for the task, exp. "Elmet Backup"
- Optionally, provide a description in the "Description" field.
- Check the box "Run whether the user is logged on or not" to ensure the script runs regardless of a logged-in user.

**4. Triggers Tab:**

- Click the "New Trigger" button.
- Choose a trigger schedule based on your needs. Here are some options:
  - **Daily:** Back up every day at a specific time.
  - **Weekly:** Back up on specific days of the week at a chosen time.
  - **Monthly:** Back up on a specific day of the month or based on a specific interval (e.g., every first Monday of the month).
  - **On a schedule:** Back up at a specific time interval (e.g., every 2 hours).
- Configure the chosen trigger frequency and time according to your desired backup schedule.

**5. Actions Tab:**

- Click the "New Action" button.
- In the "Action" field, select "Start a program".
- In the "Program/script" field, type `powershell` and in the *Add arguments (optional)* field add the following text: `-NoExit -Command "Set-Location <THE_BACKUP_SCRIPTS_FOLDER>; .\startbackup.ps1; exit;"`

> **_NOTE:_** you can repleace the _startbackup.ps1_ file with the other backup solutions specified above, based on your needs.

**6. Review and Finish:**

- Review the task details on the summary page.
- Click "OK" to create the scheduled task.

**Additional Considerations:**

- **Permissions:** Ensure the task has sufficient permissions to run the script and access the source and destination folders.
- **Test Run:** Consider running the task manually using the "Run" button in the Task Scheduler to verify its functionality before relying solely on the scheduled execution.
