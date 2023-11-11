$Outlogfile = "C:\ProgramData\Dumb_Browser_Remover.log" 
start-transcript -path $Outlogfile -Force
$users = @()
$users += Get-ChildItem -Path "C:\Users" -Directory | Where-Object {$_.Name -ne "All Users" -and $_.Name -ne "Default" -and $_.Name -ne "Default User" -and $_.Name -ne "Public"}
foreach ($user in $users) {
#Removing files start with parent folder recurse should remove all files
Remove-Item -LiteralPath "C:\Program Files\DumbBrowser\Dirs" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "C:\Users\$($user.Name)\AppData\Local\dumbBrowserr" -Recurse -Force -Verbose -ErrorAction SilentlyContinue        
}

Stop-Transcript
write-output "succeeded at removal operations"
Exit 0
