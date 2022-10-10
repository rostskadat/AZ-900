# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Tag all resources with @{"refresh"="test"}
#
$tags = @{'refresh' = 'test' }
Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME | ForEach-Object { New-AzTag -ResourceId $_.id -Tag $tags }

#------------------------------------------------------------------------------
#
# create a new load balancer
#
# Ref: https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-powershell

# Create Public IP
$PublicIpAddress = New-AzPublicIpAddress -ResourceGroupName $RESOURCE_GROUP_NAME -Name 'pub_web_ip' -AllocationMethod Static -Location $REGION_ID -Sku Standard -Zone 1
# $PublicIpAddress = Get-AzPublicIpAddress -ResourceGroupName $RESOURCE_GROUP_NAME -Name "pub_web_ip"

# Create load balancer frontend configuration
$FrontendIpConfiguration = New-AzLoadBalancerFrontendIpConfig -PublicIpAddress $PublicIpAddress -Name 'pub_web_ip'

# Create backend address pool configuration
$BackendAddressPool = New-AzLoadBalancerBackendAddressPoolConfig -Name 'pub_web_lb_bep'
$BackendAddressPool.LoadBalancerBackendAddresses = New-Object Microsoft.Azure.Commands.Network.Models.PSLoadBalancerBackendAddress

# Add existing VM to pool
# Ref: https://learn.microsoft.com/en-us/azure/load-balancer/backend-pool-management
# https://4sysops.com/archives/reading-azure-vm-name-ip-address-and-hostname-with-powershell/
$VirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName 'pluralsight-resource-group' -Name 'azlbvn'

('web01', 'web02' ) | ForEach-Object { 
    $vm = Get-AzVM -ResourceGroupName $RESOURCE_GROUP_NAME -Name $_
    $nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
    $Name = "$_" + '_IpAddress'
    $IpAddress = $nic.IpConfigurations[0].PrivateIpAddress
    $VirtualNetworkId = $VirtualNetwork.Id
    $BackendAddressConfig = New-AzLoadBalancerBackendAddressConfig -IpAddress $IpAddress -VirtualNetworkId $VirtualNetworkId -Name $Name
    $BackendAddressPool.LoadBalancerBackendAddresses.Add($BackendAddressConfig)
}
# Remove first (empty) element
$BackendAddressPool.LoadBalancerBackendAddresses.RemoveAt(0)

# In case the configuration happens after the LB creation use the following 
#Set-AzLoadBalancerBackendAddressPool -InputObject $BackendAddressPool

# Create the health probe
$Probe = New-AzLoadBalancerProbeConfig -Name 'pub_web_lb_hp' -Protocol Tcp -Port 80 -IntervalInSeconds 10 -ProbeCount 5


# Create the load balancer rule
$LoadBalancingRule = New-AzLoadBalancerRuleConfig `
    -Name 'pub_web_lb_rule' `
    -Protocol Tcp -FrontendPort 80 -BackendPort 80 `
    -IdleTimeoutInMinutes 4 `
    -FrontendIpConfigurationId $FrontendIpConfiguration.Id `
    -BackendAddressPoolId $BackendAddressPool.Id `
    -EnableTcpReset -DisableOutboundSNAT

# Finally create the LB
$LoadBalancerConfig = @{
    ResourceGroupName       = $RESOURCE_GROUP_NAME
    Name                    = 'pub_web_lb'
    Location                = $REGION_ID
    Sku                     = 'Standard'
    FrontendIpConfiguration = $FrontendIpConfiguration
    BackendAddressPool      = $BackendAddressPool
    LoadBalancingRule       = $LoadBalancingRule
    Probe                   = $Probe
}
New-AzLoadBalancer @LoadBalancerConfig
