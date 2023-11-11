#just having fun with ways to deploy a desktop shortcut or... other things...
$IconPath = 'C:\Path\To\someIcon.ps1'
$IconBytes = Get-Content $IconPath -Encoding Byte
$IconBase64 = [System.Convert]::ToBase64String($IconBytes)
$IconBase64