#create a scheduled task to wake the device from sleep at 12am daily
$tasklogger = "C:\ProgramData\waketask.txt"
Start-Transcript -Path $tasklogger -Append -Force
$logfile = "C:\ProgramData\wake.txt"
$taskName = 'WakeFromSleep'
$taskPath = '\'
$description = 'This task wakes the device when triggered.'
$date = get-date -Format "yyyy-MM-dd HH:mm:ss"
# Get the principal (task owner) SID for SYSTEM
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount

# Create the action wake device from sleep
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -Command `"Start-Transcript -Path $logfile; 'Waking device from sleep, Rise and Shine!!!'; Start-Sleep -Seconds 10; Write-Output 'Device arose from sleep $($date)'; Stop-Transcript`""
$settings = New-ScheduledTaskSettingsSet -WakeToRun:$true -AllowStartIfOnBatteries:$true -DontStopIfGoingOnBatteries:$true -StartWhenAvailable:$true -RunOnlyIfNetworkAvailable:$false 


# Create the trigger
$trigger = New-ScheduledTaskTrigger -Daily -At 12am
#Just A Test Trigger.
#$trigger2 = New-ScheduledTaskTrigger -Daily -At 2:20pm


# Register the task
$results = Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskPath -Description $description -Settings $settings -Force 
Stop-Transcript
$results
exit 0