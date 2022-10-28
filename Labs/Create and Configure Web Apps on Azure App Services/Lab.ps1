# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
#  Create an App Service to Host the Web Application
$AppServicePlan = New-AzAppServicePlan -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name "Experimental" -Tier Free


# Create a web app.
$WebAppName = "ps-web-app" + ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdef") ) -join '')

New-AzWebApp -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $WebAppName -AppServicePlan "Experimental"

#------------------------------------------------------------------------------
#
#  Create an App Service to Host the Web Application

