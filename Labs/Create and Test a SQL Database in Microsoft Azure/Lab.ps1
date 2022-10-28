# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'labResourceGroup'

#------------------------------------------------------------------------------
#
# Create a Single Database
#
New-AzResourceGroup -Name $RESOURCE_GROUP_NAME -Location $REGION_ID
$SecureString = ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdefABCDEF") ) -join '') | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList "pslearner", $SecureString
$ServerName ="labsqlserver" + ((Get-Random -Count 10 -InputObject ([Char[]]"0123456789abcdef") ) -join '')
New-AzSqlServer -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -ServerName $ServerName -ServerVersion "12.0" -SqlAdministratorCredentials $Credential
New-AzSqlDatabase -ResourceGroupName $RESOURCE_GROUP_NAME -DatabaseName "labSampleDB" -ServerName $ServerName
