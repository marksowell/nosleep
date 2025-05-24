$log = "$env:USERPROFILE\Desktop\nosleep.log"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Out-File -Append -FilePath $log
}

try {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr PowerCreateRequest(ref REASON_CONTEXT context);

    [DllImport("kernel32.dll")]
    public static extern bool PowerSetRequest(IntPtr handle, int requestType);

    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr handle);

    public const int PowerRequestExecutionRequired = 0;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct REASON_CONTEXT {
        public uint Version;
        public uint Flags;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string ReasonString;
    }
}
"@ -ErrorAction Stop

    $ctx = New-Object Power+REASON_CONTEXT
    $ctx.Version = 0
    $ctx.Flags = 1
    $ctx.ReasonString = "Prevent system sleep"
    $request = [Power]::PowerCreateRequest([ref]$ctx)

    $setResult = [Power]::PowerSetRequest($request, [Power]::PowerRequestExecutionRequired)

    if ($setResult) {
        Write-Log "nosleep.ps1 started successfully — power request set"
    } else {
        Write-Log "ERROR: PowerSetRequest failed"
    }
} catch {
    Write-Log "ERROR: Failed to load PowerRequest code — $($_.Exception.Message)"
    exit 1
}

while ($true) {
    Write-Log "Preventing sleep (active)"
    $lines = Get-Content -Path $log -ErrorAction SilentlyContinue
    if ($lines.Count -gt 10000) {
        $lines[-10000..-1] | Set-Content -Path $log
    }
    Start-Sleep -Seconds 60
}