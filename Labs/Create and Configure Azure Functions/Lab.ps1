# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Tag all resources with @{"refresh"="test"}
#
$tags = @{'refresh' = 'test' }
Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME | ForEach-Object { New-AzTag -ResourceId $_.Id -Tag $tags }

#------------------------------------------------------------------------------
#
# Get Function App 
#
$FunctionName = (Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME -ResourceType Microsoft.Web/sites)[0].Name
$Function = Get-AzFunctionApp -ResourceGroupName $RESOURCE_GROUP_NAME -Name $FunctionName

New-AzStorageAccount -ResourceGroupName AzureFunctionsQuickstart-rg -Name <STORAGE_NAME> -SkuName Standard_LRS -Location <REGION>
New-AzFunctionApp -Name <APP_NAME> -ResourceGroupName AzureFunctionsQuickstart-rg -StorageAccount <STORAGE_NAME> -Runtime dotnet -FunctionsVersion 3 -Location '<REGION>'
func azure functionapp logstream <APP_NAME> 

# Variable block
$FunctionAppName = "MyFunctionApp" + ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdef") ) -join '')
$tag = @{script = "create-function-app-consumption"}
$storage = "msdocsaccount$randomIdentifier"
$functionApp = "msdocs-serverless-function-$randomIdentifier"
$skuStorage = "Standard_LRS"
$functionsVersion = "4"

# Create an Azure storage account in the resource group.
Write-Host "Creating $storage"
New-AzStorageAccount -Name $storage -Location $REGION_ID -ResourceGroupName $RESOURCE_GROUP_NAME -SkuName $skuStorage

# Create a serverless function app in the resource group.
New-AzFunctionApp -Name $FunctionAppName -StorageAccountName $Storage -Location $REGION_ID -ResourceGroupName $RESOURCE_GROUP_NAME -Runtime DotNet -FunctionsVersion $functionsVersion