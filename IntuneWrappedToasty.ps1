$IntuneScript = @'


#Declare some housekeeping variables for where we are getting the image file, what to save it as, where to save it, and if there isnt already a spot there to make one in a subfolder under c/user/appdata/temp.
$Sitelogo = "https://imagehostedfile"
$ImageFileName = "ToastLogo.png"
$ImageDirectory = "C:\Windows\Temp\blah"
$Saveto = "C:\Windows\Temp\blah\$ImageFileName"
$EndDate = [DateTime]::new(2023, 4, 17, 23, 59, 59) #The Quit Date with time included because otherwise it'll quit at 12am that quit date. 
$Now = Get-Date


if (!(Test-Path $ImageDirectory)) {
    New-Item -ItemType Directory -Path $ImageDirectory | Out-Null
}


if ($Now -le $EndDate)
{
    if (-not (Test-Path $Saveto)) 
    {
    Invoke-WebRequest -URI $Sitelogo -OutFile $Saveto
    }
}

$xml = @"

<toast launch="reminderLaunchArg" scenario="incomingCall">
  <visual>
    <binding template="ToastGeneric">
      <text>Breaking News copilot AI is the best!, See Additional Details Below</text>
      <text>If you haven't already done so, update your contact info, Click below to access the form.</text>
      <image src='$Saveto' placement='appLogoOverride'/>
    </binding>
  </visual>
  <actions>
    <input id="idSnoozeTime" type="selection" defaultInput="360">
      <selection id="90" content="90 minutes" />
      <selection id="180" content="3 hours" />
      <selection id="360" content="6 hours" />
      <selection id="720" content="12 hours" />
      <selection id="1440" content="24 Hours" />
    </input>
   
    <action content="Update Records" arguments='https:\someSillyForm' activationType="protocol" />
    <action activationType="system" arguments="snooze" hint-inputId="idSnoozeTime" content="Remind Me Later" />
  </actions>
</toast>
"@
$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
$XmlDocument.loadXml($xml)
$AppId = 'msEdge'
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId).Show($XmlDocument)

#This removes the script totally and decommissions the task that calls the notification.
if ($EndDate -lt $Now)
{
    Unregister-ScheduledTask -TaskName "Notify" -TaskPath "Toasty" -Confirm:$false
    Remove-Item $ImageDirectory -Recurse
}
'@
 #Check if script is running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

#sketch privl.escalation
 #If script is not running as administrator, re-run it with elevated privileges & This totally works for computers with admin rights already.
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}


Set-ExecutionPolicy Bypass -Scope CurrentUser

New-Item -ItemType Directory -Path C:\Windows\Temp\Blah -Force | Out-Null
$ScriptLocation = "C:\Windows\Temp\blah\Toasty.ps1"
$IntuneScript | Out-File -FilePath $ScriptLocation -Encoding utf8
$ExpectedHash = Get-FileHash -Path "$ScriptLocation" -Algorithm SHA256 | Select-Object -ExpandProperty Hash

# Create a new scheduled task trigger to run when the user logs on and at a specific time.
$LogonTrigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERNAME"
$TimeTrigger = New-ScheduledTaskTrigger -Daily -At "5:00PM"

# Create a new scheduled task action to run the PowerShell script only if the script matches the originally sent out payload in script we used in Intune.
$RunToasty = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "-ExecutionPolicy Bypass -Command `"`$hash = (Get-FileHash -Path '$ScriptLocation' -Algorithm SHA256).Hash; if (`$hash -eq '$ExpectedHash'`) { & '$ScriptLocation' }`"" -WorkingDirectory "C:\Windows\Temp\blah"

# Create a new scheduled task principal to specify the current user account when the task is triggered.
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Create a new scheduled task settings object to hide the task in the Task Scheduler.
$TaskSettings = New-ScheduledTaskSettingsSet -Hidden

# Register the scheduled task using the system account to set up the task, but set the task to run under the current user's account when the trigger is activated.
Register-ScheduledTask -TaskName "Notify" -TaskPath "Toasty" -Trigger $LogonTrigger, $TimeTrigger -Action $RunToasty -Settings $TaskSettings -Principal $TaskPrincipal -Force
Powershell.exe -ExecutionPolicy Bypass -File $ScriptLocation
Set-ExecutionPolicy Restricted -Scope CurrentUser