# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Create a Single Database
#
$WebAppName ="myWebApp" + ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdef") ) -join '')
New-AzWebApp -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $WebAppName 