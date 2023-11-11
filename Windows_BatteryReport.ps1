# Create the battery report
$reportPath = "C:\ProgramData\battery-report.xml"
powercfg /batteryreport /output $reportPath /Xml
$systemInfo = Get-WmiObject -Class Win32_ComputerSystem
# Extract model and manufacturer
$model = $systemInfo.Model
$manufacturer = $systemInfo.Manufacturer
# Get system serial number
$serialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
# Output the information
Write-Output "Model: $model"
Write-Output "Manufacturer: $manufacturer"
Write-Output "Serial Number: $serialNumber"

# Load the battery report XML content
[xml]$xmlContent = Get-Content -Path $reportPath

# Extract device name, serial number, model, and battery capacities
$deviceName = $xmlContent.BatteryReport.SystemInformation.ComputerName
$designCapacity = $xmlContent.BatteryReport.Batteries.Battery.DesignCapacity
$fullChargeCapacity = $xmlContent.BatteryReport.Batteries.Battery.FullChargeCapacity

# Calculate the percentage of battery life lost
$capacityLossPercentage = (($designCapacity - $fullChargeCapacity) / $designCapacity) * 100

# Create a hashtable to output as a custom object
$batteryData = [PSCustomObject]@{
    deviceName = $deviceName
    serialnumber = $serialNumber
    model = $model
    designCapacity = $designCapacity
    fullChargeCapacity = $fullChargeCapacity
    capacityLossPercentage = $capacityLossPercentage
}


# Export data to CSV
$batteryData | Export-Csv -Path "C:\ProgramData\BatteryOutput.csv" -NoTypeInformation -Force

# Upload the CSV to a cloud storage service using a function called SaveToCloud
if (SaveToCloud -deviceName $deviceName -localFile "C:\ProgramData\BatteryOutput.csv")
{
remove-item  "C:\ProgramData\BatteryOutput.csv"
exit 0
}
else
{
    Write-Output "Failed to upload file"
    exit 1
}