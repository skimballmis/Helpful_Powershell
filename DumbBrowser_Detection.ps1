#detection and remediation framework for finding Dumb Browser on a machine and bringing it to justice. Or any of a million chrome like clones
$users = @()
$users += Get-ChildItem -Path "C:\Users" -Directory | Where-Object {$_.Name -ne "All Users" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" -and $_.Name -ne "Public"}
#loop through the users and program files directories and check for the Dumb browser
foreach ($user in $users) 
    {
        $path = "C:\Users\$($user.Name)\AppData\Local\Programs"
        if (Test-Path -Path $path) {
        write-output "Dumb Browser found on $($user.Name)'s machine at $path"
        #exit 1 when used with D&R causes the remediation script to run
        exit 1
        }
    }
    
#exit 0 when used with D&R causes the remediation script NOT to run
write-output "Dumb Browser not found on any user for this machine during detection at $timestamp"
exit 0

