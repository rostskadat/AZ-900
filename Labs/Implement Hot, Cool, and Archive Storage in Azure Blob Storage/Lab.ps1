# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Create an Azure Storage Account
#
$StorageName = 'strgsales' + ((Get-Random -Count 5 -InputObject ([Char[]]'0123456789abcdef') ) -join '')
$StorageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Name $StorageName -SkuName Standard_LRS -Location $REGION_ID

$Tags = @{'Environment' = 'ps-sales' }
New-AzTag -ResourceId $StorageAccount.Id -Tag $Tags

#------------------------------------------------------------------------------
#
# Setting Up Azure Blob Storage
#
$ContainerName = 'ps-sales'
New-AzStorageContainer -Name $ContainerName -Context $Context -Permission Blob

# Uploading...
$UploadBlob = @{
    File             = 'Sales-2018.csv'
    Container        = $ContainerName
    Blob             = 'Sales-2018.csv'
    Context          = $Context
    StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @UploadBlob

# Downloading ...
$DownloadBlob = @{
    Blob        = 'Sales-2018.csv'
    Container   = $ContainerName
    Destination = '.'
    Context     = $Context
}
Get-AzStorageBlobContent @DownloadBlob

# List the blobs in a container
Get-AzStorageBlob -Container $ContainerName -Context $Context 

#------------------------------------------------------------------------------
#
# Connect and Access Azure Blob Storage Using C#
#
$key1 = Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME $StorageName | Where-Object { $_.KeyName -eq 'key1' }
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageName;AccountKey=" + $key1.Value
$SasUrl = "https://strgsalesc5aed.blob.core.windows.net/?sv=2021-06-08&ss=bfqt&srt=o&sp=rtfx&se=2022-10-21T00:12:57Z&st=2022-10-20T16:12:57Z&spr=https&sig=Wi9HpJPmNIBxnMRrou2MeUMVXL8V18U%2BY8ftYy0XdYc%3D"

#------------------------------------------------------------------------------
#
# Change the Storage Tier for Objects in Blob Storage
#
$Blob = Get-AzStorageBlob -Container $Containername -Context $Context -Blob "Sales-2018.csv"

$Blob.ICloudBlob.SetStandardBlobTier("Cool")

#------------------------------------------------------------------------------
#
# Define Object Lifecycle
#
# Optionally enable access time tracking
Enable-AzStorageBlobLastAccessTimeTracking -ResourceGroupName $RESOURCE_GROUP_NAME -StorageAccountName $StorageName -PassThru

# Create a new action object.
$Action = Add-AzStorageAccountManagementPolicyAction            -BaseBlobAction Delete           -daysAfterModificationGreaterThan 2555
Add-AzStorageAccountManagementPolicyAction -InputObject $Action -BaseBlobAction TierToArchive    -daysAfterModificationGreaterThan 1825
Add-AzStorageAccountManagementPolicyAction -InputObject $Action -BaseBlobAction TierToCool       -daysAfterModificationGreaterThan 730
Add-AzStorageAccountManagementPolicyAction -InputObject $Action -SnapshotAction Delete           -daysAfterCreationGreaterThan 2555
Add-AzStorageAccountManagementPolicyAction -InputObject $Action -BlobVersionAction TierToArchive -daysAfterCreationGreaterThan 1825

# Create a new filter object.
$Filter = New-AzStorageAccountManagementPolicyFilter -PrefixMatch "ps-sales/Sales" -BlobType blockBlob

# Create a new rule object.
$Rule = New-AzStorageAccountManagementPolicyRule -Name "rl-sales-compliance" -Action $Action -Filter $Filter

# Create the policy.
Set-AzStorageAccountManagementPolicy -ResourceGroupName $RESOURCE_GROUP_NAME -StorageAccountName $StorageName -Rule $Rule

