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

# create the bastion subnet
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name "app-vnet"
$Subnet = @{
    VirtualNetwork = $VirtualNetwork
    Name           = 'AzureBastionSubnet'
    AddressPrefix  = '10.0.0.0/25'
}
Add-AzVirtualNetworkSubnetConfig @Subnet
$VirtualNetwork | Set-AzVirtualNetwork
get-childite

# create the bastion subnet
$BastionSubnet = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name app-vnet | Get-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet"

# create the IP address
$PublicIpAddress = New-AzPublicIpAddress -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -AllocationMethod Static -Name 'app-vnet-pip' -Sku Standard -Zone 1

# create the bastion
$Bastion = New-AzBastion -ResourceGroupName $RESOURCE_GROUP_NAME -VirtualNetworkId $VirtualNetwork.Id -PublicIpAddressId $PublicIpAddress.Id -Name "azubast01"

# retrieve the SSH keys...
# get the storage account
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.StorageAccountName -match 'lab' } | Select-Object -First 1

$StorageShare = Get-AzStorageShare -Context $StorageAccount.Context
# get the ssh key
Remove-Item -Force id_rsa -ErrorAction Ignore
Get-AzStorageFileContent -Context $StorageAccount.Context -ShareName $StorageShare.Name -Path id_rsa

# get VM
$VM = Get-AzVM -ResourceGroupName $RESOURCE_GROUP_NAME -Name "appvm01"

#------------------------------------------------------------------------------
#
# Restrict Access with Network Security Groups (NSGs)
#
New-AzNetworkSecurityGroup -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name "application-nsg"
$NetworkSecurityGroup = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCE_GROUP_NAME -Name "application-nsg"

# Add the inbound security rule.
$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'in-ssh_rdp-from-bastion-to-virtual-network-allow' `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix '10.0.0.0/25' `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange (22, 3389)

$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'in-https-from-any-to-frontend-allow' `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix '10.0.2.0/24' `
    -DestinationPortRange 443

$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'in-http_8080-from-frontend-to-backend-allow' `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 120 `
    -SourceAddressPrefix '10.0.2.0/24' `
    -SourcePortRange * `
    -DestinationAddressPrefix '10.0.3.0/24' `
    -DestinationPortRange 8080

$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'in-any-from-any-deny' `
    -Access Deny `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 4096 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange *

# Update the NSG.
$NetworkSecurityGroup | Set-AzNetworkSecurityGroup

# And associate
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name "app-vnet"
foreach ($Subnet in $VirtualNetwork.Subnets) {
    if ($Subnet.Name -ne 'AzureBastionSubnet') { 
        $Subnet.NetworkSecurityGroup = $NetworkSecurityGroup 
    }
}
$VirtualNetwork | Set-AzVirtualNetwork

#------------------------------------------------------------------------------
#
# Secure Outbound Traffic with Azure Firewall
#
# Add subnet: NOTE: MUST BE CALLED 'AzureFirewallSubnet'
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name "app-vnet"
$Subnet = @{
    VirtualNetwork = $VirtualNetwork
    Name           = 'AzureFirewallSubnet'
    AddressPrefix  = '10.0.1.0/24'
}
Add-AzVirtualNetworkSubnetConfig @Subnet
$VirtualNetwork | Set-AzVirtualNetwork

# create the IP address
$FWPublicIpAddress = New-AzPublicIpAddress -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -AllocationMethod Static -Name 'azufw-pip' -Sku Standard -Zone (1, 2, 3)

# create fw policy 
$FWPolicy = New-AzFirewallPolicy -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'azufw-policy'

New-AzFirewall -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'azufw' -VirtualNetwork $VirtualNetwork -PublicIpAddress $FWPublicIpAddress

$Firewall = Get-AzFirewall -ResourceGroupName $RESOURCE_GROUP_NAME -Name 'azufw'

# get the effective Network Security Group
Get-AzEffectiveNetworkSecurityGroup -ResourceGroupName $RESOURCE_GROUP_NAME -NetworkInterfaceName 'webvm01-nic'

# Create a routing table
$RouteTable = New-AzRouteTable -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'routetable01'

$FWPrivateIPAddress = $Firewall.IpConfigurations[0].PrivateIPAddress

# Add route to route table
Get-AzRouteTable -ResourceGroupName $RESOURCE_GROUP_NAME -Name 'routetable01' | `
    Add-AzRouteConfig -Name "default-to-firewall" -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $FWPrivateIPAddress | `
    Set-AzRouteTable


# you can also use the Add-AzRouteConfig
#PS>  Add-AzRouteConfig -Name "default-to-firewall" -AddressPrefix "0.0.0.0/0" -NextHopType "VirtualAppliance" -NextHopIpAddress $FWPrivateIPAddress -RouteTable $RouteTable
# or the New-AzRouteConfig
#PS> $Route = New-AzRouteConfig -Name "default-to-firewall" -AddressPrefix "0.0.0.0/0" -NextHopType VirtualAppliance -NextHopIpAddress $FWPrivateIPAddress
#PS> $RouteTable.Routes = $Route
#PS> $RouteTable | Set-AzRouteTable

# And associate with frontend and backend subnet
$FrontendSubnet = Get-AzVirtualNetworkSubnetConfig -Name "FrontendSubnet" -VirtualNetwork $VirtualNetwork
$FrontendSubnet.RouteTable = $RouteTable 
$BackendSubnet = Get-AzVirtualNetworkSubnetConfig -Name "BackendSubnet" -VirtualNetwork $VirtualNetwork
$BackendSubnet.RouteTable = $RouteTable 
$VirtualNetwork | Set-AzVirtualNetwork

# Then add some rules
<# $FWRuleCollectionGroup = #> New-AzFirewallPolicyRuleCollectionGroup -ResourceGroupName $RESOURCE_GROUP_NAME -FirewallPolicyName $FWPolicy.Name -Priority 100 -Name "application-rule-collection-group-01"
$FWRuleCollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -ResourceGroupName $RESOURCE_GROUP_NAME -AzureFirewallPolicyName $FWPolicy.Name -Name "application-rule-collection-group-01"

$newrule1 = New-AzFirewallPolicyApplicationRule -Name "googleapis-allow" -Description "Allow all google APIs call" -SourceAddress ("10.0.2.0/24","10.0.3.0/24") -Protocol ("http", "https") -TargetFqdn ("*.googleapis.com", "google.com", "www.google.com")

$FWFilterRuleCollection = New-AzFirewallPolicyFilterRuleCollection -Name "application-rule-collection-01" -Priority 100 -Rule $newrule1 -ActionType Allow
$FWRuleCollectionGroup.Properties.RuleCollection.Add($FWFilterRuleCollection)
Set-AzFirewallPolicyRuleCollectionGroup -Name "application-rule-collection-group-01" -Priority 100 -FirewallPolicyObject $FWPolicy -RuleCollection $FWRuleCollectionGroup.Properties.RuleCollection