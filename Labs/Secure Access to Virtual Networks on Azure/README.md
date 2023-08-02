# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/4e7b0ab6-e6d8-4bbd-b09f-d85f6808704d/toc)

# Secure Management Access to VMs with Azure Bastion

You were recently hired by an e-commerce company called Globomantics as an Azure Administrator. Your company is considering a cloud migration and wants to run a proof-of-concept in Azure. They started by migrating one application consisting of two VMs: a web frontend and a backend. They want you to ensure that the environment is well secured before the testing activities start.

The Cloud Engineering team created a virtual network and two subnets to which they deployed the frontend and the backend VMs, as shown in the diagram:figure﻿

Your job is to deploy an Azure Bastion so that the VMs can be securely accessed via SSH.

1. Log in to the Azure portal navigate to the Bastions service using the search bar at the top of the page. 

2. On the Bastions page, click on Create.

    Note: If you see an error when you reach the Bastions page or find any missing resources during creation, wait a few minutes for the resources to load properly and then refresh the page. You can also go find the missing resource and add a Name tag to it and that should help you find it during creation more easily.

3. Fill in the form as follows:

        Subscription: Leave the one that is selected by default, this has been created for you 

        Resource group: Select the resource group named pluralsight-resource-group 

        Name: azubast01

        Region: East US

        Virtual network: app-vnet (if missing from dropdown, see note below)

        Note: It is common for the virtual network to be missing from the dropdown menu, and it can sometimes take as long as 30 minutes from the time you begin this lab to the time it finally appears there. There's a chance, however, that the following steps will cause it to appear immediately. First, use the search bar at the top of the page to navigate to the Virtual Networks service and click on the virtual network named app-vnet. Click the Click here to add tags link, then add a tag with a Name of test and a Value of refresh. Click Save, then navigate back to the Bastions service and try to add a Bastion as instructed above. After following these steps the virtual network should appear. If not, you may need to wait for up to 30 minutes for it to appear on its own. We apologize for the inconvenience, and have adjusted the challenge completion time accordingly.

        Subnet: Click on Manage subnet configuration 

    The Azure Bastion service requires that the bastion be deployed on an isolated subnet named AzureBastionSubnet with a prefix of at least /26. That way the bastion service can scale to meet demands properly and Microsoft can deliver on its SLAs. You'll create that subnet next.

4. Click  + Subnet to add a subnet. 

5. In the Name field, type AzureBastionSubnet. In Address range, type 10.0.0.0/25. Leave all other fields with their default values and click Save.

6. Back on the Subnets page, click on Refresh a few times until you see that newly created subnet in the list. Now click on the ‘X’ icon on the top-right corner to close this page and go back to the Bastion creation form. Or, click on Create a Bastion in the navigation breadcrumbs on the top-left corner of the page, to the left of app-vnet, which will also take you back.

7. Continue filling in the Bastion creation form as follows:

        Public IP address: Create new 

        Public IP address name: app-vnet-pip

8. Click on Review + create. Then click on Create. This will take a few minutes; in the meantime, you can continue.

    To verify that everything works correctly, you will try to SSH into the VMs using Azure Bastion. An SSH key-pair was already generated for the VMs used in this lab and stored in an Azure Storage Account. You will download the private key next, so that you can use it with Azure Bastion.

9. In the Azure portal, click on the search bar on the top and type in storage accounts, then hit enter. Or, click on Storage accounts when that appears under the Services group as you type.

10. Click on the storage account with the name that starts with lab (not the one that starts with diag). 

10. On the left-side menu for the storage account, scroll down to the Data storage settings group, then click on File shares.

10. On the File shares configuration blade, click on the file share with a name that starts with lab.

10. On the file share Overview page, you should see two files listed: id_rsa and id_rsa.pub.  Click on ida_rsa. 

10. On the File properties context menu that opens, click on Download. Specify a path on your local computer to save the file and note the location.

10. Head again to the top search bar in the portal and type in virtual machines, then hit enter. 

10. On the Virtual Machines page, click on appvm01.

    Before moving on to the next task, make sure the Azure Bastion deployment has completed by clicking on the notifications bell icon on the right corner of the top bar in the portal. If not, wait until it does before proceeding.

10. In the virtual machine Overview blade, click on Connect, then click on Bastion. Finally, click Use Bastion.

10. Under Username, type azuser. For Authentication Type, select SSH Private Key from Local File. Click on the box where it says Select a file under Local File, and specify the path to the file you downloaded previously. 

10. Click Connect.

A new tab or window in your browser should open with a web-based SSH console, and you should be logged in to the appvm01 VM, as shown in the image below. You may be asked to allow the bastion service to access your clipboard. For the best experience, it is recommended that you grant that permission. Note that if you have restrictions in your operating system’s firewall regarding websocket traffic this may not work for you, unless you explicitly allow it.

Congratulations! you have now deployed and configured Azure Bastion service and used it to open an SSH session to a VM.

# Restrict Access with Network Security Groups (NSGs)

Without NSGs, access within the environment and from the outside is overly permissive. The frontend VM has a public IP and is vulnerable to attacks by being open to the Internet. Full connectivity within the environment is also a security risk. 

Your job is to now restrict network access using NSGs following the zero-trust principle. The development team said that they need the frontend servers to access the backend servers on HTTP port 8080, and the frontend servers to be accessible over the Internet on HTTPS port 443. 

You'll begin by verifying that, currently, VMs can access each other on any port. 

1. If not still open, open a new SSH session to appvm01 using Azure Bastion as you learned in the previous challenge. 

2. From the appvm01 SSH terminal, run the command:

    nc -vz webvm01 22

    Verify that the output says:

    Connection to webvm01 22 port [tcp/ssh] succeeded!

    This means that the SSH port (or any port, for that matter) is accessible in those VMs since there are no security rules blocking it. Although clients still need the private key to SSH into VMs, it is a security best practice to only allow port communications that are needed, and to block (or deny) everything else to reduce the attack surface. This is one aspect of the zero-trust principle, and it helps prevent the lateral movement of intruders if there’s ever a breach within the environment, thus preventing further damage to the systems.  

    Leave the tab or window with the SSH terminal open.

3. Back in the Azure Portal, click on the search bar on the top and type network security groups, then hit enter. Or, click on Network security groups when it appears under the Services group as you type. 

4. Click on Create. 

5. On the Create a network security group page, leave the Subscription field with the default selected, then select the  resource group named pluralsight-resource-group from the Resource group dropdown. 

6. Under Instance details, fill in the form fields as follows:

        Name: application-nsg

        Region: (US) East US

    Click on Review + create. Then click on Create. Wait until deployment completes before moving on.

7. In the Azure portal, click on the search bar on the top and type in application-nsg. Then, click on application-nsg which should appear under the Resources menu group after you type the name.

8. On the left-side menu, click on Inbound security rules. Then click on Add.

9. Fill in the Add inbound security rule form as follows:

        Source: IP Addresses

        Source IP addresses/CIDR ranges: 10.0.0.0/25

        Source port ranges: *

        Destination: Service Tag

        Destination service tag: VirtualNetwork

        Destination port ranges: 22, 3389

        Protocol: TCP

        Action: Allow

        Priority: 100

        Name: in-ssh_rdp-from-bastion-to-virtual-network-allow

        Description: [leave empty]

    Click on Add.

10. Still on Inbound security rules page, click on Add to add another security rule. 

11. Fill in the Add inbound security rule form as follows:

        Source: Any

        Source port ranges: *

        Destination: IP Addresses

        Destination IP addresses/CIDR ranges: 10.0.2.0/24

        Destination port ranges: 443

        Protocol: TCP

        Action: Allow

        Priority: 110

        Name: in-https-from-any-to-frontend-allow

        Description: [empty]

    Note the different priority value. In Azure, two NSG rules in the same direction (e.g. inbound) cannot have the same priority value. Also note that the lower the value, the higher the priority. In other words, priority numbers are evaluated in ascending order of their values, so the lowest values are evaluated first. When a match happens, no further NSG rules will be evaluated. This effectively means that a rule with a lower priority value will always “overwrite” or take precedence over any other contradicting rules with higher priority values. The maximum value you can pick (and therefore the lowest priority) is 4096.

12. Click Add to finish that inbound security rule. 

13. Still on the Inbound security rules page, click on Add to add another security rule. 

14. Fill in the Add inbound security rule form as follows:

        Source: IP Addresses

        Source IP addresses/CIDR ranges: 10.0.2.0/24

        Source port ranges: *

        Destination: IP Addresses

        Destination IP addresses/CIDR ranges: 10.0.3.0/24

        Destination port ranges: 8080

        Protocol: TCP

        Action: Allow

        Priority: 120

        Name: in-http_8080-from-frontend-to-backend-allow

        Description: [empty]

    Azure NSGs have three default rules with priority values of 65000, 65001, and 65500. The last rule is aptly named DenyAllInbound since it denies all inbound traffic from any source. However, there’s another rule, the one with priority value 65000 (and therefore taking precedence), that allows traffic within the Virtual Network. This may be convenient and OK for development and testing environments, but it’s not recommended in a real, production environment, which is why you’re going to overwrite this overly permissive rule with another rule denying all inbound traffic. And it’s also why you just added a rule to allow the specific communication needed from frontend towards backend subnets, which is on TCP port 8080, before denying all other inbound access.

15. Click Add to finish that inbound security rule. 

16. Still on Inbound security rules, click on Add to add one last security rule. 

17. Fill in the Add inbound security rule form as follows:

        Source: Any

        Source port ranges: *

        Destination: Any

        Destination port ranges: *

        Protocol: Any

        Action: Deny

        Priority: 4096

        Name: in-any-from-any-deny

        Description: [empty]

    Now that the security rules are defined, you need to associate the NSG to the subnets so that they actually apply to the inbound traffic on the subnets. You will leave outbound rules with the default ones. 

    Note that it is possible to associate an NSG with either a subnet or a VM’s network interface card. It is often better from a management perspective to keep them only associated with Subnets. Microsegmentation of traffic is still possible to achieve by specifying IP addresses or Application Security Groups in source and/or destination fields, so this comes at no real loss of granularity.

18. Click Add to finish that last inbound security rule.

19. Still on the application-nsg page, now click on Subnets on the left-side menu,

20. Click on Associate.

21. From the Virtual network dropdown menu, select app-vnet. In the Subnet field, select BackendSubnet, then click on OK.

22. Repeat the previous two tasks, this time selecting FrontendSubnet in the Subnet field.

To verify that you’ve got everything set up properly, click on Overview in the left-hand menu, and you should see Inbound security rules and Outbound security rules as shown in the image below:

Note in particular the rules with priority values 100, 110, and 120, which should allow the specific communications you need (check the Action column for those, as well as Source, Destination, Protocol and Port fields to see if your configuration matches the expected values). Finally, note the rule with priority 4096, which should have a Deny action, and both source and destination are Any. 

Congratulations! You have successfully applied NSGs to an Azure Virtual Network to enforce the zero-trust principle and keep it more secure. 

# Validate Connectivity and Evaluate Effective Security Rules

You now need to verify connectivity in the environment and to evaluate what are the effective security rules on both VMs.

1. In the Azure Portal, click on the search bar on the top, and type webvm01. Then, click on webvm01 which should appear under the Resources menu group after you type the name.

2. In the Overview blade, under the Properties section in the middle of the page and in the Networking sub-group, note down the value of the Public IP address property. Then click on Connect and select Bastion. 

3. Since it’s the first time using Bastion for this VM, click Use Bastion to enable bastion connectivity for this VM.

    Under Username, type azuser. For Authentication Type, select SSH Private Key from Local File. Click on Select a file under Local File, and specify the path to the file you downloaded previously (it’s the same private key for both VMs). Next, click on Connect.

    Keep that SSH terminal open, and navigate back to the browser tab or window where the SSH terminal for appvm01 is. If you no longer have that terminal open, repeat the steps you followed previously to open a new SSH terminal to appvm01 using Azure Bastion.

    In the appvm01 SSH terminal, run the following command: 

    nc -vz webvm01 22 -w 3

    The command should time out after 3 seconds, as now it shouldn’t be possible for one VM to access another on SSH port. 

    Still in the appvm01 SSH terminal, run the following command: 

    python -m SimpleHTTPServer 8080

    This will run a very simple web server on port 8080. 

    Now in the webvm01 SSH terminal window/tab, run the following command: 

    nc -vz appvm01 8080 -w 3

    The output should be: 

    Connection to appvm01 8080 port [tcp/http-alt] succeeded!

    This connectivity is one you allowed, as requested by the development team.

    Back in the appvm01 SSH terminal, press Ctrl+C to terminate the web application, and run the following command (now on port 8888): 

    python -m SimpleHTTPServer 8888

    Now in the webvm01 SSH terminal again, repeat the connectivity test, this time on the new port where the web server is running which is 8888. Run the following command: 

    nc -vz appvm01 8888 -w 3

    This time you should see that the connectivity times out after 3 seconds. Even though the server is now running on that port, our NSGs are now blocking all inbound traffic to appvm01 except for TCP port 8080 from the frontend subnet.

    Finally, let’s see if you have successfully restricted inbound traffic from the Internet. Still in the webvm01 SSH terminal, start the python web server on port 443:

    sudo python -m SimpleHTTPServer 443

    Note that you need sudo this time.

    In task two above you noted the public IP for webvm01; append :443 to this IP and then paste it into a new browser tab and hit enter. You should see a page that looks like this:

    ﻿figure﻿

    That Python web server simply lists the files in the current directory, which is why you’re seeing this. Note that it’s not actual TLS-encrypted web traffic which is why you will see a warning in your browser that the connection is not secure (and also why you should not prefix the URL with https:// as this is just an HTTP application running on port 443. We’re trying to simply validate the port connection).

    You can optionally repeat this task, this time replacing the port number 443 with another port number, such as 80 or 8080. Then try accessing it with your browser on the new port number and you should see that the connection times out. 

    Because NSGs can be associated with subnets (as an alternative to or in conjunction with network interfaces), it can be confusing to know which rules apply to a VM. However, Azure provides an easy way to see what are the effective security rules on a particular VM’s network interface card (NIC), based on the subnet it is in (and based on any NSGs associated to the network interface as well). 

    In the Azure portal, click on the search bar on the top, and type webvm01, then click on webvm01 under the Resources menu group when it appears.

    Click on Networking on the left-side menu under the Settings group. On the networking configuration blade, click on Effective security rules in the middle of the page, next to the name of the network interface (webvm01-nic). 

    On the Effective security rules page, note the Inbound rules and Outbound rules lists (it may take a few seconds for the page to load). You should be seeing the NSG rules you previously created, as well as the default Azure-provided rules. You can optionally click on Download to download this table as a CSV file.

    Repeat steps 12 through 13 for vm appvm01 to confirm that its effective security rules are those created under BackendSubnet-nsg. 

You should see the same outputs indicated under each task where an SSH command is run and an output is shown. In the last task you should also see a section in the page (Effective security rules) in your browser looking similar to this:

﻿figure






