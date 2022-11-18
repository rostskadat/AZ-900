# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Get CosmosDB account
#
$CosmosDBAccount = Get-AzCosmosDBAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.Name -match 'cosmosterraformdemoversion*' }

# create database
$Database = New-AzCosmosDBSqlDatabase -ParentObject $CosmosDBAccount -Name 'ToDoDatabase'

# create container
$Container = New-AzCosmosDBSqlContainer -ParentObject $Database -Name 'ToDoList' -Throughput '400' -PartitionKeyKind Hash -PartitionKeyPath '/category' 

# Get the keys
$Keys = Get-AzCosmosDBAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME -Name $CosmosDBAccount.Name

#------------------------------------------------------------------------------
#
# Feed Data to the Cosmos DB Container
#

$config = @{
    "host" = $CosmosDBAccount.DocumentEndpoint
    "master_key" = $Keys["PrimaryMasterKey"]
    "database_id" = $Database.Name
    "container_id" = $Container.Name
}

Write-Host "Should generate the config.py with the value extracted from the different elements ($Container, etc.)"
Write-Host "Run the python script in sql-python, making sure you get the proper config.py"