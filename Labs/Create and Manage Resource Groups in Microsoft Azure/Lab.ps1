# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'Globomantics_new'

#------------------------------------------------------------------------------
#
# Manage a Resource Group Using Azure Portal
#
$ResourceGroup = New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location $REGION_ID -Tags @{ 
    'GloboTag1' = 'TagValue1'
    'GloboTag2' = 'TagValue2'
}

Remove-AzResourceGroup -Id $ResourceGroup.ResourceId

#------------------------------------------------------------------------------
#
# Start the Azure Cloud Shell
#
