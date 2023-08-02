# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'globomantics_rg'

#------------------------------------------------------------------------------
#
# Create SQL User Accounts
#
# The server name: Use a random value or replace with your own value (don't capitalize)
$ServerName = "server-$(Get-Random)"
# Set an admin name and password for your database
# The sign-in information for the server
$AdminLogin = "globomantics_admin"
$password = "4-v3ry-53cr37-p455w0rd"
# The ip address range that you want to allow to access your server - change as appropriate
$MyIp = (Invoke-WebRequest -uri "https://api.ipify.org/").Content
# The database name
$DatabaseName = "StaffAnalyticsDW"


# $SqlServer = New-AzSqlServer -Location $REGION_ID `
#     -ResourceGroupName $RESOURCE_GROUP_NAME `
#     -ServerName $ServerName `
#     -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AdminLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

$SqlServer = Get-AzSqlServer -ResourceGroupName $RESOURCE_GROUP_NAME | Select-Object -First 1

New-AzSqlServerFirewallRule -ResourceGroupName $RESOURCE_GROUP_NAME `
    -ServerName $SqlServer.ServerName `
    -FirewallRuleName "AllowSome" -StartIpAddress $MyIp -EndIpAddress $MyIp

New-AzSqlDatabase `
    -ResourceGroupName $RESOURCE_GROUP_NAME `
    -ServerName $SqlServer.ServerName `
    -DatabaseName $DatabaseName `
    -Edition "DataWarehouse" `
    -RequestedServiceObjectiveName "DW100c" `
    -CollationName "SQL_Latin1_General_CP1_CI_AS" `
    -MaxSizeBytes 10995116277760

# Cf. https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/quickstart-bulk-load-copy-tsql-examples
