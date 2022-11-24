# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Granting Access Policies to User Profile
#
$KeyVault = Get-AzKeyVault -ResourceGroupName $RESOURCE_GROUP_NAME

# Principal for AD App / service: Get-AzADServicePrincipal -SearchString <search-string>
# Principal for AD Group: Get-AzADGroup -SearchString <search-string>
# Principal for user:
$Principal = Get-AzAdUser -UserPrincipalName (Get-AzAccessToken).UserId

Set-AzKeyVaultAccessPolicy -ResourceGroupName $RESOURCE_GROUP_NAME `
    -VaultName $KeyVault.VaultName `
    -ObjectId $Principal.Id `
    -PermissionsToSecrets all `
    -PermissionsToKeys all 

# Create the key
Add-AzKeyVaultKey -VaultName $KeyVault.VaultName -Name "key1" -Destination "Software"
$Key1 = Get-AzKeyVaultKey -VaultName $KeyVault.VaultName -KeyName "key1"

# Create the secret
$SecretValue = ConvertTo-SecureString "hVFkk965BuUv" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name "SQLPassword" -SecretValue $SecretValue
Get-AzKeyVaultSecret -VaultName $KeyVault.VaultName -Name "SQLPassword" -AsPlainText