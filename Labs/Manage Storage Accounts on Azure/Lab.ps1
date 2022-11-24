# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'Storage'

#------------------------------------------------------------------------------
#
# Create and Access Azure Storage Accounts
#
$StorageAccountName = "sa$(Get-Random)"
New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $StorageAccountName -SkuName Standard_LRS

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $StorageAccountName

# Retrieve the keys
$Keys = Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME -Name $StorageAccountName

$Keys[0].Value
$Keys[1].Value

# Generate a Shared Access Signature Using the Azure Portal
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.StorageAccountName -match 'storage*' } 
$Container = Get-AzStorageContainer -Context $StorageAccount.Context -Name media
foreach ($container in (Get-AzStorageContainer -Context $StorageAccount.Context -Prefix media)) {
    Write-Host $container.Name 'properties:'
    $container.BlobContainerClient.GetProperties().Value
}

$Blob = Get-AzStorageBlob -Context $StorageAccount.Context -Container $Container.Name

# Generate SAS (shared access signature)
$startTime = Get-Date
$expiryTime = $startTime.AddDays(7)
# Approach 1: Generate SAS token for a specific container
$sas = New-AzStorageContainerSASToken `
    -Context $StorageAccount.Context `
    -Name $Container.Name `
    -StartTime $startTime `
    -ExpiryTime $expiryTime `
    -Permission 'rwl' `
    -Protocol 'HttpsOnly'

# Approach 2: Generate SAS tokens for a container list using pipeline
$sas = Get-AzStorageContainer -Container $Container.Name -Context $StorageAccount.Context | New-AzStorageContainerSASToken `
-Context $StorageAccount.Context `
-StartTime $startTime `
-ExpiryTime $expiryTime `
-Permission 'rwl' `
-Protocol 'HttpsOnly' | Write-Output

# Configure Virtual Network Access
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name productionnetwork
$Subnet = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name productionnetwork | Get-AzVirtualNetworkSubnetConfig -Name datainfra

# BEWARE: if you have the error:
# The following networks don’t have service endpoints enabled for 'Microsoft.Storage'. Enabling access will take up to 15 minutes to complete. After starting this operation, it is safe to leave and return later if you do not wish to wait.

# To allow traffic from all networks, use the Update-AzStorageAccountNetworkRuleSet command, and set the -DefaultAction parameter to Allow.
# To allow traffic only from specific virtual networks, use the Update-AzStorageAccountNetworkRuleSet command and set the -DefaultAction parameter to Deny.
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $RESOURCE_GROUP_NAME -Name $StorageAccount.StorageAccountName `
    -DefaultAction Deny `
    -VirtualNetworkRule @{VirtualNetworkResourceId=$Subnet.id;Action="allow"}


#------------------------------------------------------------------------------
#
# Create a Private Endpoint
#
# Quickstart: Create an ASP.NET Core web app in Azure.
$WebAppName = "LabStorageAccount"
dotnet new webapp -n $WebAppName --framework net6.0
cd $WebAppName
New-AzWebApp -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $WebAppName

$WebApp = Get-AzWebApp -ResourceGroupName $RESOURCE_GROUP_NAME  -Name $WebAppName

dotnet.exe publish --configuration release

cd bin\Release\net6.0\publish
Compress-Archive -Path * -DestinationPath deploy.zip
Publish-AzWebApp -ResourceGroupName $WebApp.ResourceGroup -Name $WebApp.Name -ArchivePath (Get-Item .\deploy.zip).FullName -Force
# $pec = @{
#     Name = 'productionendpoint'
#     PrivateLinkServiceId = $WebApp.Id
#     GroupID = 'sites'
# }
#$privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec
#Start-Process "https://$($WebApp.DefaultHostName)/"

# Create a private endpoint

## Create the private endpoint connection. ## 
$pec = @{
    Name = 'productionendpoint'
    PrivateLinkServiceId = $StorageAccount.Id
    GroupID = 'blob'
}
$privateEndpointConnection = New-AzPrivateLinkServiceConnection @pec

## Create the private endpoint. ##
New-AzPrivateEndpoint -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'productionendpoint' -Subnet $Subnet -PrivateLinkServiceConnection $privateEndpointConnection

$PrivateEndpoint = Get-AzPrivateEndpoint -ResourceGroupName $RESOURCE_GROUP_NAME -Name 'productionendpoint'


nslookup.exe "$($StorageAccount.StorageAccountName).blob.core.windows.net"