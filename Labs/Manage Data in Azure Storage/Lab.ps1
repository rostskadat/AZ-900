# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Install Storage Explorer
#
$Bastion = Get-AzVM -ResourceGroupName $RESOURCE_GROUP_NAME | Select-Object -First 1

$URL = 'https://download.microsoft.com/download/A/E/3/AE32C485-B62B-4437-92F7-8B6B2C48CB40/StorageExplorer.exe'

# Install Storage Explorer
Invoke-AzVMRunCommand -ResourceGroupName $RESOURCE_GROUP_NAME -VMName $Bastion.Name `
    -CommandId 'RunPowerShellScript' `
    -ScriptString "Invoke-WebRequest -Uri $URL -OutFile D:\StorageExplorer.exe"

# Install AzCopy
$URL = 'https://azcopyvnext.azureedge.net/release20221108/azcopy_windows_amd64_10.16.2.zip'
Invoke-AzVMRunCommand -ResourceGroupName $RESOURCE_GROUP_NAME -VMName $Bastion.Name `
    -CommandId 'RunPowerShellScript' `
    -ScriptString "Invoke-WebRequest -Uri $URL -OutFile D:\azcopy_windows_amd64_10.16.2.zip"
