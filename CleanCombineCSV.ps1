# Define the path to the folder containing the baby CSV files
$folderPath = "P:\FolderOfidenticalBabyReports"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH"


# Define the path for the new combined CSV file
$combinedCsvPath = "G:\SomeReport_$timestamp.csv"

#create the file
New-Item -Path $combinedCsvPath -ItemType File -Force


# Define your own headers
$customHeaders = "Device-Name,Serial,Model,FactoryCapacity,CurrentMaxCapacity,CapacityLossPercentage" # etc., match these to the columns in the CSV files

# Create a new CSV file and add the custom headers
Set-Content -Path $combinedCsvPath -Value $customHeaders

# Get a list of all CSV files in the folder
$csvFiles = Get-ChildItem -Path $folderPath -Filter *.csv

# Iterate over each CSV file
foreach ($file in $csvFiles) {
    # Get the content of the file, skipping the first line (headers)
    $content = Get-Content -Path $file.FullName | Select-Object -Skip 1 -Verbose
    
    # Append the content to the combined CSV file
    Add-Content -Path $combinedCsvPath -Value $content
}

# Output to console the completion
Write-Host "CSV files have been combined into $combinedCsvPath"
