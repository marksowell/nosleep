# nosleep

No Sleep is a simple PowerShell script that prevents a Windows virtual machine (or physical machine) from entering sleep mode. It's useful for ensuring continuous uptime during long-running tasks, testing environments, or remote access sessions.

## Features

- Blocks system sleep (S1/S3/S0 idle)
- Logs activity every minute to a rotating log file
- Logging is capped at 10,000 lines to prevent excessive disk usage.
- Configurable as a scheduled task to auto-start at boot
- Requires no external dependencies
- The script uses native Windows APIs via Add-Type to request the system stay awake.
- Compatible with Windows 10/11 and most Windows Server versions.

## 🔧 Setup Instructions

### Step 1: Download the PowerShell Script

1. Open PowerShell as Administrator and run:
   
   ```powershell
   Invoke-WebRequest -Uri "https://github.com/marksowell/nosleep/raw/main/nosleep.ps1" -OutFile "$env:USERPROFILE\Desktop\nosleep.ps1"
   ```

### Step 2: Register as a Scheduled Task (Auto-Start at Boot)

1. Open PowerShell as Administrator and run:
   
   ```powershell
   $scriptPath = "$env:USERPROFILE\Desktop\nosleep.ps1"
   $me = "$env:USERDOMAIN\$env:USERNAME"
   $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
   $trigger = New-ScheduledTaskTrigger -AtStartup
   $principal = New-ScheduledTaskPrincipal -UserId $me -RunLevel Highest
   
   Unregister-ScheduledTask -TaskName "PreventS1Sleep" -Confirm:$false -ErrorAction SilentlyContinue
   Register-ScheduledTask -TaskName "PreventS1Sleep" -Action $action -Trigger $trigger -Principal $principal
   ```

### Step 3:Start the Script Immediately (No Reboot Required)

1. Start the scheduled task:
   
   ```powershell
   Start-ScheduledTask -TaskName "PreventS1Sleep"
   ```

3. Verify it’s working:

   ```powershell
   Get-Content -Tail 5 "$env:USERPROFILE\Desktop\nosleep.log"
   ```

   Example output:
   
   ```powershell
   2025-05-23 14:02:00 - nosleep.ps1 started successfully — power request set
   2025-05-23 14:03:00 - Preventing sleep (active)
   ```

4. (Optional) Get detailed information:

   ```powershell
   Get-ScheduledTask -TaskName "PreventS1Sleep" | Get-ScheduledTaskInfo
   ```

## Removal Instructions

1. Delete the scheduled task:
   
   ```powershell
   Unregister-ScheduledTask -TaskName "PreventS1Sleep" -Confirm:$false
   ```
3. Delete the files from your Desktop:
   
   - nosleep.ps1
   - nosleep.log
