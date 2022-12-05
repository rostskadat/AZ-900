# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/dd22bf53-4d59-4760-a224-7b498df5e5f1/toc)

https://www.tutorialspoint.com/how-to-get-azure-vm-activity-logs-using-powershell

# Setup Azure Cloud Shell

Your work for Carved Rock Fitness, a regional manufacturer of rock climbing gear. To increase security as well as reduce complexity and cost, your organization has decided to move to a role-based access control (RBAC) model. As part of your role as a security administrator in the cybersecurity team, it falls within your responsibility to secure resources in Microsoft Azure using role-based access control.

This lab will use a mix of Azure Portal, a web-based console with a graphical user interface, and PowerShell, Microsoft's scripting and automation environment using the command line, to give you a broad exposure to administering Azure.

In this challenge you'll be setting up Azure Cloud Shell to enable access to PowerShell. Before getting started, make sure the lab environment has finished loading. This may take a few minutes.

1. To the right of these instructions, use the Email, Password, and Open Azure portal button provided by this lab to log in to the portal.

2. Click on the Cloud Shell icon which is located immediately to the right of the search bar at the top of the page, and in the resulting Welcome to Azure Cloud Shell pane, click the PowerShell link.

3. Click Show advanced settings, select East US from the Cloud Shell region dropdown.

4. In the Resource group section, choose Use existing, then select the resource group named pluralsight-resource-group.

    Note: If the resource group is not yet available, you won't be able to select Use existing. You'll need to wait a minute for the lab to finish loading, then close the cloud shell pane and retry.

5. While leaving the Cloud Shell open, use the search bar at the top of the page to navigate to the Storage accounts service.  Locate the storage account whose name starts with lab. Enter that name (including the four random characters) in the Storage account field in the cloud shell advanced settings. Make sure that you select the Create new radio button.

    Note: Even though the storage account is already created, this will just create a link to the currently existing storage account that sometimes doesn't show up in the Use existing list while the brand new lab is still spinning up. In a normal environment, you would probably just be able to use the Use existing radio button and select the storage account from the list.

6. For File share, enter the same name as you did for the Storage account field. Click Create storage.

Setting up Azure Cloud Shell may take a few minutes. Once your setup is complete, you'll see the following at the bottom half of your screen. Your username will look slightly different since it is unique to your lab environment.

