# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/63dbed72-7a25-43cd-83f4-46362a469ea7/toc)

https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy?tabs=azure-powershell
https://learn.microsoft.com/en-us/azure/key-vault/keys/quick-create-powershell
https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-powershell

# Setting Up Your Cloud Shell Environment

You have been asked to configure a key and secret in Azure KeyVault using the Cloud Shell. However, before you get started, you'll need to setup your Cloud Shell environment for use. In this scenario, you will use the following steps to spin up an Azure Cloud Shell terminal.

1. Once they're available, use the button and login information to the right of these instructions to log in to the Azure Portal.

    It will take about five minutes for the lab environment to load, and for the button and login information to become available.

2. From the Azure Portal, navigate to the top right and select the Cloud Shell icon.

3. A Cloud Shell window appear at the bottom of your browser. From the options, select Bash

4. On the next screen, there will be an option to mount storage. Select Show advanced settings

5. You'll need to change the Cloud Shell region to East US

6. Under Storage account select Use existing and a randomized value will appear in the box below. 

    Note: If Use existing is greyed out, click All resources on the Azure Home page. Copy the Name of the Storage account. Back in the Cloud Shell panel, leave Create new selected, and paste in the storage account name.

7. Under File share enter pslab01 , then select the Create storage button

Now allow a moment for the Cloud Shell environment to configure and for your terminal to connect. When you see prompts in your terminal similar to what is shown below, you are ready to move onto the next challenge:

```shell
Requesting a Cloud Shell.Succeeded.

Connecting terminal...

Welcome to Azure Cloud Shell

pluralsight-XXXXXXXX@Azure:~$
``` 

# Granting Access Policies to User Profile

1. From the Azure portal, navigate to search bar at the top of your browser and search for Key vaults under Services 

2. After the Key Vaults service dashboard has loaded, you will find a single Key Vault instance pre-existing in your lab environment. Under Name, click the key vault link to open the configuration settings for that vault.

3. In the left-hand pane, open Access policies, then click + Create.

4. From the Configure from a template drop-down menu, select Key & Secret Management from the options.

5. Click the Principal tab.

6. In the tab's search bar, enter your Azure account's email, the one you used when logging in. Then, click the result to select it.

    It will start with pluralsight-.

    You can also see is by, in the upper-right, clicking View account.

7. Click the Review + create tab, then click Create.

Now your Azure Cloud Shell will have the ability to create and destroy keys using the account access granted.

Move onto the next challenge where we will begin managing keys in Azure Key Vault.

# Creating Keys and Secrets in Azure Key Vault

1. At the top of the Access policies page, copy the the Key vault name (for example, it will be something like pssacsqc71671s1dcd7v)

2. Go to the Cloud Shell prompt, replace <keyvaultname> with the value you just copied, and execute the following command

```
    vault_name=$(az keyvault list | jq -r '.[0].name')
    az keyvault key create --name "key1" --vault-name "$vault_name"
```

    Note: If you get an error saying, roughly, your user does not have create permission, go back, and re-do the tasks in the previous challenge. Ensure you select the exact username you used to log into Azure.

3. In the left-hand menu of the Key vault, click Keys.

    You should now see a freshly created key named key1 in the list. Next, you'll create a secret in the key vault using the Cloud Shell. 

4. Replace <keyvaultname> with the Key vault name, and in the Cloud Shell, execute the following command

    az keyvault secret set --name "SQLPassword" --value "hVFkk965BuUv" --vault-name <keyvaultname>

    The command should look similar to the following:

    az keyvault secret set --name "SQLPassword" --value "hVFkk965BuUv" --vault-name pssacsqc71671s1dcd7v

5. Finally, execute the command. 

To confirm that your secret was created successfully, select Secrets from the left menu of the Key vault. You should see an enabled SQLPassword, which you created using the terminal command you entered in the Cloud Shell.

In this lab, you've learned how to create and configure Azure KeyVaults, Keys, and Secrets using the Cloud Shell Command-Line Interface - Great job! Be sure to explore the attached Azure documentation to learn more about working with Cloud Shell to manage Azure KeyVault resources.

