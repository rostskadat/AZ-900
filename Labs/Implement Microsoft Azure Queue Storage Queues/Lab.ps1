# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Manage Queues Using Microsoft Azure Storage Explorer
#
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.StorageAccountName -match 'azurequeueslab*' }
# $StorageName = 'azurequeueslab' + ((Get-Random -Count 5 -InputObject ([Char[]]'0123456789abcdef') ) -join '')
# $StorageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $StorageName -SkuName Standard_LRS

$Context = $StorageAccount.Context
$Incoming = New-AzStorageQueue -Name 'incoming-messages' -Context $Context
$Outgoing = New-AzStorageQueue -Name 'outgoing-messages' -Context $Context

#------------------------------------------------------------------------------
#
# Create an HTTP Triggered Azure Function That Writes a Message to a Queue
#
$FunctionName = (Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME -ResourceType Microsoft.Web/sites)[0].Name
$Function = Get-AzFunctionApp -ResourceGroupName $RESOURCE_GROUP_NAME -Name $FunctionName

$Settings = Get-AzFunctionAppSetting -ResourceGroupName $RESOURCE_GROUP_NAME -Name $FunctionName 

$key1 = Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME $StorageAccount.StorageAccountName | Where-Object { $_.KeyName -eq 'key1' }
$ConnectionString = 'DefaultEndpointsProtocol=https;AccountName=' + $StorageAccount.StorageAccountName + ';AccountKey=' + $key1.Value
$Settings['QueueStorageAccount'] = $ConnectionString

# Create the function itself:
# func init AzureQueuesLabFunctions --dotnet
# cd AzureQueuesLabFunctions
# func new --name IncomingRequestHandler --template "HttpTrigger" --authlevel "function"
# func new --name ProcessRequestHandler --template "QueueTrigger" --authlevel "function"


Update-AzFunctionAppSetting -ResourceGroupName $RESOURCE_GROUP_NAME -Name $FunctionName -AppSetting $Settings -Force

#------------------------------------------------------------------------------
#
# Create an Queue Triggered Azure Function Using Bindings
#


#------------------------------------------------------------------------------
#
# Create an HTTP Monitoring Endpoint to Report on Queue Statistics
#


#------------------------------------------------------------------------------
#
# Connect a Logic App to a Queue Trigger to Save a Database Record
#
$TableName = "SupportRequests"
New-AzStorageTable -Name $TableName -Context $Context
