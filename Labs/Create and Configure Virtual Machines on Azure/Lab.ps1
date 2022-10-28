# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
#  Create a virtual machine
#

# Create Resource Group
$rg = @{
    Name = $RESOURCE_GROUP_NAME
    Location = $REGION_ID
}
New-AzResourceGroup @rg

# setup credentials
[string]$userName = 'azurelabadmin'
[string]$userPassword = 'L234FOmdwer#2'
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

# create virtual subnets
$vnet = @{
    Name = 'vnet-lab-001'
    ResourceGroupName = $RESOURCE_GROUP_NAME
    Location = $REGION_ID
    AddressPrefix = '10.0.0.0/16'    
}
$virtualNetwork = New-AzVirtualNetwork @vnet
$subnet = @{
    Name = 'snet-lab-001'
    VirtualNetwork = $virtualNetwork
    AddressPrefix = '10.0.0.0/24'
}
$subnetConfig = Add-AzVirtualNetworkSubnetConfig @subnet
$virtualNetwork | Set-AzVirtualNetwork

# Get a Public IP
$ip = @{
    Name = 'vm-lab-win001-ip'
    ResourceGroupName = $RESOURCE_GROUP_NAME
}
Get-AzPublicIpAddress @ip | Select-Object IpAddress

$vm = New-AzVMConfig -VMName "vm-lab-win001" -VMSize "Standard_DS1_v2"
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName "vm-lab-win001" -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

# Shorthand way:

$text = "Add-WindowsFeature Web-Server; Add-Content -Path `"C:\inetpub\wwwroot\Default.htm`" -Value $($env:computername)";
$UserData = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($text));


$vmdetails = @{
    ResourceGroupName = $RESOURCE_GROUP_NAME
    Location = $REGION_ID
    Name = "vm-lab-win001"
    VirtualNetworkName = "vnet-lab-001"
    SubnetName = "snet-lab-001"
    Credential = $cred
    Size = "Standard_DS1_v2"
    Image = "Win2019Datacenter"
    PublicIpSku = "Standard"
    UserData = $UserData
}


New-AzVM @vmdetails 

# Missing:
# - Opening Port 80
# - Create Vault + key
# - encrypt the disks

