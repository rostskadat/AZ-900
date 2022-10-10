# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Create Logic App 
#

$LogicAppName = "MyLogicApp" + ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdef") ) -join '')
New-AzLogicApp -ResourceGroupName $RESOURCE_GROUP_NAME -Name $LogicAppName -Location $REGION_ID -DefinitionFilePath Definition.json

