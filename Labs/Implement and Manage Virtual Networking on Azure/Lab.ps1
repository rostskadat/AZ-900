# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Create a Virtual Network
#
$vnet = @{
    ResourceGroupName = $RESOURCE_GROUP_NAME
    Location = $REGION_ID
    Name = 'eastus-vnet'
    AddressPrefix = '10.100.0.0/16'    
}
$EastUSVirtualNetwork = New-AzVirtualNetwork @vnet

$Subnet = @{
    VirtualNetwork = $EastUSVirtualNetwork
    Name = 'web'
    AddressPrefix = '10.100.0.0/24'
}
$SubnetConfig = Add-AzVirtualNetworkSubnetConfig @Subnet

$EastUSVirtualNetwork | Set-AzVirtualNetwork

#------------------------------------------------------------------------------
#
# Connect Virtual Networks with Virtual Network Peering
$WestUSVirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $RESOURCE_GROUP_NAME -Name "westus-vnet"
Add-AzVirtualNetworkPeering -Name 'eastus-to-westus' -VirtualNetwork $EastUSVirtualNetwork -RemoteVirtualNetworkId $WestUSVirtualNetwork.Id
Add-AzVirtualNetworkPeering -Name 'westus-to-eastus' -VirtualNetwork $WestUSVirtualNetwork -RemoteVirtualNetworkId $EastUSVirtualNetwork.Id


#------------------------------------------------------------------------------
#
# Create a Network Security Group
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'eastus-web-nsg' 
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $EastUSVirtualNetwork -Name $SubnetConfig.Subnets[0].Name -NetworkSecurityGroup $NetworkSecurityGroup -AddressPrefix 10.100.0.0/24

## Update the subnet configuration. ##
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $EastUSVirtualNetwork -Name $SubnetConfig.Subnets[0].Name -NetworkSecurityGroup $NetworkSecurityGroup
Set-AzVirtualNetwork -VirtualNetwork $EastUSVirtualNetwork

# Add HTTPS & RDP inbound rule
$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'AllowHttpsInBound' -Priority 3891 -Access Allow -Protocol Tcp -Direction Inbound -SourceAddressPrefix "*" -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
$NetworkSecurityGroup | Add-AzNetworkSecurityRuleConfig -Name 'AllowRdpInBound'   -Priority 3892 -Access Allow -Protocol Tcp -Direction Inbound -SourceAddressPrefix "*" -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

# Update the NSG.
$NetworkSecurityGroup | Set-AzNetworkSecurityGroup

#------------------------------------------------------------------------------
#
# Create a Public IP Address
$ip = @{
    Name = 'eastus-web-ip'
    ResourceGroupName = $RESOURCE_GROUP_NAME
    Location = $REGION_ID
    Sku = 'Basic'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
}
$IpAddress = New-AzPublicIpAddress @ip

#------------------------------------------------------------------------------
#
# Create a Network Interface

# Create primary configuration for NIC. ##
$IpConfig1 = @{
    Name = 'ipconfig1'
    Subnet =  (Get-AzVirtualNetwork -Name 'eastus-vnet').Subnets[0]
    PrivateIpAddressVersion = 'IPv4'
    PrivateIpAddress = "10.100.0.4"
    PublicIPAddress = $IpAddress
}
$IpConfiguration = New-AzNetworkInterfaceIpConfig @IpConfig1 -Primary

# Command to create network interface for VM ##
New-AzNetworkInterface -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'eastus-web-nic' -IpConfiguration $IpConfiguration

#------------------------------------------------------------------------------
#
# Create a Public Virtual Machine
$SecureString = 'P@$$w0rd1234!' | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList 'azure-user', $SecureString

New-AzVm `
    -ResourceGroupName $RESOURCE_GROUP_NAME `
    -Location $REGION_ID `
    -Name 'eastus-web' `
    -VirtualNetworkName $EastUSVirtualNetwork.Name `
    -SubnetName $EastUSVirtualNetwork.Subnets[0].Name `
    -Credential $Credential
#    -OpenPorts 80,3389
#    -SecurityGroupName 'myNetworkSecurityGroup' `
#    -PublicIpAddressName $IpAddress.Name `
# Install web server
Invoke-AzVMRunCommand -ResourceGroupName $RESOURCE_GROUP_NAME -VMName 'eastus-web' -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'

#------------------------------------------------------------------------------
#
# Create a Route Table
$RouteTable = New-AzRouteTable -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name 'eastus-web-rt'
$RouteTable | Add-AzRouteConfig -Name 'data-via-nva' -AddressPrefix 10.0.1.0/24  -NextHopType 'VirtualAppliance' -NextHopIpAddress 10.0.0.4 | Set-AzRouteTable