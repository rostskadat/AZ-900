# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'Cosmos'

#------------------------------------------------------------------------------
#
# Get CosmosDB account
#
$CosmosDBAccount = Get-AzCosmosDBAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.Name -match 'cosmos-*' }

# create database
#$Database = New-AzCosmosDBSqlDatabase -ParentObject $CosmosDBAccount -Name 'Retail'
$Database = Get-AzCosmosDBSqlDatabase -ParentObject $CosmosDBAccount -Name 'Retail'

# create container
#$Container = New-AzCosmosDBSqlContainer -ParentObject $Database -Name 'Customers' -Throughput '400' -PartitionKeyKind Hash -PartitionKeyPath '/category' 
$Container = Get-AzCosmosDBSqlContainer -ParentObject $Database -Name 'Customers'

# Create store procedure
$StoredProcedure = New-AzCosmosDBSqlStoredProcedure -ParentObject $Container -Name generateRecord -Body (Get-Content "generateRecord.js").ToString()


# Create UDF
$UserDefinedFunction = New-AzCosmosDBSqlUserDefinedFunction -ParentObject $Container -Name generateRecord -Body (Get-Content "formatDate.js").ToString()


$URL = "$($CosmosDBAccount.DocumentEndpoint)dbs/$($Database.Name)/colls/$($Container.Name)/sprocs/$($StoredProcedure.Name)"

$Headers = @{
    "Authorization" = "Bearer $((Get-AzAccessToken).Token)"
    "Content-Type" = "application/json"
    "x-ms-date" = (Get-Date -Format R)
}

# Invoke-WebRequest -Method Post -Uri $URL -Headers $Headers -Body '["Third record", "123456789"]'
# Invoke-RestMethod -Method Post -Uri $URL -Headers $Headers -Body '["Third record", "123456789"]'

$URL = "$($CosmosDBAccount.DocumentEndpoint)dbs/$($Database.Name)/colls/$($Container.Name)/docs"
$Headers = @{
    "Authorization" = "Bearer $((Get-AzAccessToken).Token)"
    "Content-Type" = "application/query+json"
    "x-ms-date" = (Get-Date -Format R)
}
Invoke-WebRequest -Method Post -Uri $URL -Headers $Headers -Body '{"query":"SELECT d.description, d.reading, udf.formatDate(d.stamp) AS date FROM docs d"}'



