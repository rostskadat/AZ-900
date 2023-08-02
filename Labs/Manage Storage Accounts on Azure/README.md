# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/6617680f-fc2c-4572-a16b-001463131c09/toc)

https://learn.microsoft.com/en-us/azure/storage/blobs/blob-containers-powershell
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/ps-common-network-ref
https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security?tabs=azure-powershell
https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints
https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-powershell?tabs=static-ip#prerequisites
https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net60&pivots=development-environment-psget

# Create and Access Azure Storage Accounts

GloboMantics has just wrapped up a significant migration of virtualized infrastructure from an on-premises Hyper-V deployment to Azure. While the migration was successful, the operations (ops) team has found it challenging to manage all of the metadata and log files stored on each machine.

The ops team currently uses various third-party software packages that output logs and data to each virtual machines’ local file system. Today, the ops team needs to log into each virtual machine individually to review the files. The ops team has identified Azure Storage as an ideal solution to store all files, but does not have enough experience to recommend it for immediate usage.

As a new team member, your task is to evaluate Azure Storage and define a management strategy that the ops team can use moving forward. The ops team would like to use access keys to access Azure Storage accounts with full privileges. Specifically, they would like to obtain access keys to connect to Azure Storage accounts from first-party and third-party software.

After a quick review, the security team concluded that access keys could pose a risk if they were inadvertently exposed. The ops team needs to find a way to mitigate this risk to move forward with its plan for Azure Storage.

Your first task is to review how to create and access Azure Storage accounts in the portal. You will also demonstrate how access keys can be obtained and then recycled regularly.

1. Click Open Azure portal to access the lab environment, then use the provided credentials to log in.

2. In the portal, in the top search bar, type in and click on Storage accounts. Click + Create.

3. In the Basics tab of the Create storage account wizard, perform the following actions:

        In the Resource group list, select the Storage resource group that was created on your behalf in the sandbox subscription.

        In the Storage account name box, enter any globally unique name.

        🎫 Pro-tip: The Azure Portal will automatically check to see if the name is globally unique.

        Leave the remaining fields set to their default values.

        Select Review + create.

4. In the Review + create tab of the Create storage account wizard, perform the following actions:

        Review the default settings that will be applied to your new storage account.

        Select Create.

        Wait for the deployment to complete before continuing with this challenge.

        🎫 Pro-tip: The deployment status blade will let you know when the deployment is complete.

5. In the top search box, type in and click on Storage accounts.

    ❗ Note: Observe the two storage accounts in the resource group. If you don't see the one you just created, click Refresh. It may take a few minutes to populate.

6. Within the resource group, click the existing Azure Storage account link that begins with a prefix of storage, and includes a suffix of random alphanumeric characters. This Azure Storage account was created on your behalf in the sandbox subscription.

7. On the Storage account blade, observe the details in the Essentials pane.

    ❗ Note: The Essentials pane contains metadata about the Azure Storage account that you will use for the remaining challenges in this lab. This account has already been pre-populated with the assets you need for each challenge.

8. Still on the Storage account blade, on the left under Security + networking, select Access keys.

    ❗ Note: In the Access keys section, observe the values for key1 and key2.

9. Within the key1 header, select the Rotate key ⟳ icon to generate a new key. In the Regenerate access key pop-up dialog, select Yes.

10. Within the key2 header, select the Rotate key ⟳ icon to generate another new key. In the Regenerate access key pop-up dialog, select Yes.

You should now have two newly generated keys in the Access Keys section of the blade. The key recycling process you demonstrated would satisfy the security team requirement to avoid sustained data leaks if any ops team member accidentally exposes a key.

# Generate a Shared Access Signature Using the Azure Portal

There are a few admittedly rare scenarios where the ops team would like to share a log or data file with an external team member. For example, they may want to share a crash log with a developer in the organization.

To accomplish this goal, the ops team needs a mechanism to share individual blobs in the Azure Storage account[s] without exposing their administrator keys to the entire organization.

You will accomplish this by using the Azure Portal to generate a shared access signature (SAS) token for a typically inaccessible blob due to it being in a private container.

1. Still in the Storage account from the previous challenge, on the left under the Data storage section, select Containers.

2. In the Containers section, click the pre-existing media container from the list of containers.

3. In the media Container panel, click the pre-existing header.jpg block blob.

4. In the header.jpg Blob panel, copy the value in the URL box.

5. Open a new browser tab/window and navigate to the URL you just copied.

    ❗ Note: You will get a PublicAccessNotPermitted (an HTTP 409) error response indicating that public access is not enabled for the container or blob.

6. Return to the browser tab/window with the Azure Portal.

7. Back in the header.jpg Blob panel, perform the following actions:

        Select the Generate SAS tab.

        Leave all settings at their default values and select Generate SAS token and URL.

        Copy the value in the Blob SAS URL box.

8. Open a new browser tab/window and navigate to the Blob SAS URL you just copied.

The shared access signature (SAS) that was appended to the end of the URL contains the appropriate credentials needed to access the blob using only the permissions and time window designated at the time of creation. You generated a SAS token that allowed you to access a protected blob using your browser. Your team can either use the portal or an automation script to generate SAS tokens whenever they need to share files throughout the organization.

# Configure Virtual Network Access

The security team is back with a new requirement. The team would like to ensure that the Storage Account is only accessible from previously vetted networks.

GloboMantics already has a security team approved virtual network deployed to Azure. The ops team’s network administrator created a virtual network subnet for the Virtual Machines that generate logs and data.

Now you will configure the Azure Storage account only to allow access from your pre-existing virtual network and subnet.

Note: The resources needed ahead may be missing from their respective drop-down menus, and it can sometimes take as long as 30 minutes from the time you begin this lab to the time they appear. The following steps can help them to appear immediately. First, open the Portal menu by clicking the three bars in the top-left of the page. In the left-hand menu that appears, click on All resources. Select the check box at the top of the list of resources to select all resources, then click the Assign tags button. In the Assign tags blade, add a tag with a Name of test and a Value of refresh. Click Save, then continue with the tasks below. If some resources are missing, you may need to wait for up to 30 minutes for them to appear on their own. We apologize for the inconvenience, and have adjusted the challenge completion time accordingly.

1. Return to the storage account created on your behalf. On the left, from the Security + networking section of the navigation menu, select Networking,

2. In the Firewalls and virtual networks tab, perform the following actions:

        In the Allow access from section, select Selected networks.

        In the Virtual networks section, select + Add existing virtual network.

3. In the Add networks pop-up dialog, perform the following actions:

        Leave the Subscription list set to its default value.

        From the Virtual networks list, select only the productionnetwork option.

        ❗ Note: If you don't see this, it is likely still being created or isn't yet visible. See the Note at the top of this challenge.

        In the Subnets list, select only the datainfra option.

        ❗ Note: At this point, you will get a warning indicating that you must enable service endpoints for the Microsoft.Storage resource type.

        Select Enable.

        Wait for the service endpoint to be enabled.

        Select Add.

4. Back in the Firewalls and virtual networks section, select Save.

5. Expand the productionnetwork virtual network resource node from the list of Virtual Networks.

The list of authorized virtual networks will now exclusively contain the productionnetwork virtual network resource. It also contains metadata about the subnet that you configured for exclusive virtual network access. You have now configured your Azure Storage account, so it is only accessible from that virtual network and subnet you specified.

# Create a Private Endpoint

The development team was recently briefed on the ops team’s efforts to implement Azure Storage for log and data collection. The development team is excited at the possibility of accessing the Azure Storage account through code and building automation solutions to enhance many business processes throughout the organization.

In an earlier challenge, you set up the Azure Storage account, which is only accessible from within a virtual network. It would help if you created an endpoint so developers can access the Azure Storage account without using a public IP address.

1. In the left-hand menu click Overview. 

2. In the Essentials section, copy the first value for the Location header, the primary region, and store it somewhere you can retrieve it later (a text file on your device).figure
   ❗ Note: When it's time to create a private endpoint, we want to ensure we create it in the same primary region as the Azure Storage account.

3. On the left under the Security + networking section, select Networking, and then select the Private endpoint connections tab.

4. In the Private endpoint connections tab, select + Private endpoint.

5. In the Create a private endpoint wizard, select the Basics tab, and then perform the following actions:

        Leave the Subscription list set to its default value.

        Leave the Resource group list set to its default value.

        In the Name box, enter productionendpoint

        In the Region list, select the same region as the primary region of your Azure Storage account.

        Select Next: Resource.

6. Still within the Create a private endpoint wizard, now within the Resource tab, perform the following actions:

        In the Target sub-resource list, select blob.

        Select Next: Virtual Network.

7. Still within the Create a private endpoint wizard, now within the Virtual Network tab, perform the following actions:

        In the Virtual network list, select productionnetwork.

        In the Subnet list, select datainfra (10.1.0.0/24).

        Select Next: DNS.

8. Now on the DNS tab, ensure Integrate with private DNS is set to Yes, 

9. Click Next: Tags and then Next: Review + create.

10. Still within the Create a private endpoint wizard, now within the Review + create tab, perform the following actions:

        Observe the default settings that will be applied to your new private endpoint.

        Select Create.

        Wait for the deployment to complete before continuing with this challenge.

        🎫 Pro-tip: The deployment status blade will let you know when the deployment is complete. This will take about three to five minutes.figure﻿

        Select Go to resource.

11. On the Private endpoint resource blade, locate the Essentials pane and record the name of the Private link resource, as you will use it later on in the challenge.

    ❗ Note: This recorded value is the name of the Azure Storage account created on your behalf in the sandbox subscription. You will use this value to verify the DNS records for the private link resource.

12. At the top of the page, to the right of the search box, click the Cloud Shell >_ icon.

13. In the new Cloud Shell pane, select Bash.

14. Click Show advanced settings.

15. At the You have no storage mounted panel, enter the following:

        For Cloud Shell region, choose East US.

        For Resource group keep Use existing and choose Storage.

        For Storage account choose Use existing and select the one you created earlier in the lab.

            Note: If you don't see the storage account listed there and you can't select Use existing (this is due to an intermittent Azure bug), you can select Create new, and type in the name of the storage account you created earlier, and it will link up appropriately.

        For File share, choose Create new, and type in fileshare

    Click Create storage.

16. Within the Cloud Shell, execute the following command to perform a DNS lookup of the Azure Storage account:

    nslookup <private-link-resource-name>.blob.core.windows.net

    ❗ Note: Replace the <private-link-resource-name> placeholder with the name of the Private link resource you recorded previously in this challenge.

You should now have a list of DNS endpoints for the Azure Storage account. That list includes a DNS record with a suffix of .blob.core.windows.net that represents the public endpoint, and at least one more DNS record with a suffix of .privatelink.blob.core.windows.net that represents your private endpoint. You have deployed a Private Link endpoint that the development team can use to access the Azure Storage account from within a virtual network. 

# List Geo-replication Endpoints

One of the development team members researched Azure Storage and recommended that the ops team uses the Read-access Geo-redundant storage tier. The team member wanted to take advantage of the capability to query both the primary and secondary endpoints for an Azure Storage account.

As the person leading the Azure Storage research project, you want to give the development team member the correct URIs to issue HTTP requests to either the primary or secondary endpoints for your Azure Storage account. 

1. Return to the storage account created on your behalf. 

    ❗ Note: You may do so by typing storage in the search bar at the top of the screen and selecting the storageXXXXXXXXXX Storage account under the Resources section.

2. From the left-hand menu, under the Data management section, select Geo-replication.

    ❗ Note: In the Geo-replication section, observe the Primary and Secondary locations for your Azure Storage account. Your locations may be different as they are largely dependent on where the sandbox subscription deploys your Azure Storage account.

3. Within the Storage endpoints section, select View all.

4. Within the Storage account endpoints pop-up dialog, observe the values in the various boxes including Secondary Blob Service Endpoint, Primary ADLS file system endpoint, and Secondary static website endpoint.

5. At the top of the left-hand menu, select Overview.

You can now share the HTTP API endpoint URLs with the development team to build solutions that send requests to both the primary and secondary endpoints.








