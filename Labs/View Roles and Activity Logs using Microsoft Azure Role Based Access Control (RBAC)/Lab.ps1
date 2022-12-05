# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Secure Management Access to VMs with Azure Bastion
#
# tag all resources to populate the different resources
foreach ($resource in Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME) {
    New-AzTag -ResourceId $resource.ResourceId -Tag @{'test' = 'refresh' }
}

# View a List of Roles Assigned to You
$UserId = (Get-AzAccessToken).UserId
Get-AzRoleAssignment -SignInName $UserId | Format-List DisplayName, RoleDefinitionName, Scope


# View a List of Roles Assigned to a Resource Group
Get-AzRoleAssignment -ResourceGroupName $RESOURCE_GROUP_NAME | Format-Table ObjectType, ObjectId, DisplayName

# View the List of Built-in and Custom Roles
$SubscriptionId = (Get-AzSubscription).Id
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" | Format-Table ObjectType, ObjectId, DisplayName

# View Activity Logs
Get-AzLog | Where-Object {$_.Level -eq "Warning"} | Select-Object @{N='UserId';E={$UserId}}, @{N='Message';E={$_.OperationName.LocalizedValue}}, Level, Caller, EventTimestamp


