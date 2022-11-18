# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/3ede6f2e-1eea-406f-89f9-35e8f55b9c23/toc)



# Create a Virtual Network

You work for a tech startup called Carved Rock Software as a full-stack developer. You are in charge of all application infrastructure, which is currently hosted in the West US region of Azure.

The company recently closed its latest round of investment which will allowed it to expand into the east coast US market. In order to improve application performance and availability for east coast customers, the CTO has decided to run the application’s web-tier across multiple Azure regions.

Your job is to implement a new virtual network in the East US region of Azure, and securely peer it to the West US virtual network to ensure the West US data-tier can be accessed by the East US web-tier.

Note: This lab will be preloaded with the required resources needed to complete it. Because of this, please allow 5 to 10 minutes for your environment to fully load.

1. Click the Open Azure portal link to the right of these instructions, then use the provided credentials to log in. 
2. In the top left corner, under Azure services, click Create a resource.
3. In the Search services and marketplace search bar, type virtual network and select the Virtual network result.
4. Click Create to open the Create virtual network form, and enter or select the following values:
        Resource group: select the sandbox resource group starting with pluralsight-
        Name: eastus-vnet
        Region: East US
5. Click Next : IP Addresses > to proceed to the IP Addresses section.
6. Under the IPv4 address space heading, click on the first list item to change it into an input field. Change the pre-populated address space value to 10.100.0.0/16.
7. Click Add subnet to open the subnet creation blade, and enter the following values:
        Subnet name: web

        Subnet address range: 10.100.0.0/24

8. Click Add to close the subnet creation blade.
9. Click Review + create to proceed to the validation step, and then click Create to submit the form.

Once you click the Create button, after a few moments, a Your deployment is complete message will appear.

# Connect Virtual Networks with Virtual Network Peering

Now that you have created the East US network, it must be peered with the existing West US network to enable low-latency, high-bandwidth connectivity between the resources in each network.

1. Click Go to resource to view the Overview page of the new eastus-vnet  virtual network.
2. In the Settings section of the left sidebar, click Peerings, and then click Add.
3. Under This virtual network, in the Peering link name input field, enter a peering name of eastus-to-westus.
4. Under Remote virtual network, in the Peering link name input field, enter a peering name of westus-to-eastus.
5. In the Virtual network drop-down, select the westus-vnet option.

    Note: This virtual network should have been created automatically for you when you started the lab, but it is common for it to be missing from this drop-down menu. If that's the case, the following steps might help cause it to appear immediately. First, use the search bar at the top of the page to navigate to the Virtual Networks service and click on the westus-vnet virtual network. Next, click the Click here to add tags link, then add a tag with a Name of test and a Value of refresh. Click Save, then navigate back to eastus-vnet resource and follow the above steps to try adding a peering again. After following these steps the virtual network should appear; if not, you may need to wait for up to 30 minutes for it to appear on its own. We apologize for the inconvenience, and have adjusted the challenge completion time accordingly.

6. Click Add to submit the form.

After a few moments, you’ll see a new peering in the Peerings table, with a Name of eastus-to-westus and a Peering status of Connected.

# Create a Network Security Group

You decide it would be prudent to configure security rules on the West US web subnet such that traffic from outside the virtual networks will be denied if it is not HTTPS or RDP traffic.U

1. Use the search bar at the top of the page to navigate to the Network security groups page.
2. Click Create to open the Create network security group form, and enter or select the following values:
        Resource group: select the sandbox resource group starting with pluralsight-
        Name: eastus-web-nsg
        Region: East US

3. Click Review + create to proceed to the validation step, and then click Create.
4. Wait for the deployment to complete, and then click Go to resource.
5. In the Settings section of the left sidebar, click Inbound security rules, and then click Add to open the Add inbound security rule blade.
6. Select HTTPS for the Service, enter a Name of AllowHttpsInBound, and click Add, then wait for the rule to finish the creation process. 

    Note: If you move too quickly on this step and create the next rule before this one is finished, you may run into issues attempting to connect to a virtual machine later in this lab. If this happens, come back and remake this RDP rule. 
7. Create another inbound security rule, this time selecting RDP for the Service, and entering a Name of AllowRdpInBound.
8. In the Settings section of the left sidebar, click Subnets, and then click Associate.
9. Select the eastus-vnet for the Virtual network, then select web for the Subnet, and then click OK.

If you navigate back to the Overview screen for the eastus-web-nsg resource and look at the top right of the screen, you will see 2 inbound, 0 outbound under the Custom security rules subheading, and 1 subnets, 0 network interfaces under the Associated with subheading. You may need to wait a bit and click Refresh before you see this.

# Create a Public IP Address

In preparation for the creation of a virtual machine in the East US network, your next job is to create a static, public (IPv4) IP address.

1. Click the hamburger button at the top left, and then click Create a resource.
2. In the Search services and marketplace search bar, type public ip address and select the Public IP address result.
3. Click Create to open the Create public IP address form, and enter or select the following values:

        SKU: Basic

        Name: eastus-web-ip

        IP address assignment: Static

        Resource group: select the sandbox resource group starting with pluralsight-

        Location: East US
4. Click Create to submit the form.

You'll see a notification once your deployment is successful. If you click Go to resource in the notification (which you can see by clicking the notification bell in the top right if it disappears) and then look at the top right of the screen, you will be able to view the newly generated static public IP address under the IP address subheading.

# Create a Network Interface

Now that you have a public IP address, your next task is to create a network interface with a private IP address, and assign the previously created IP address to this network interface.

1. Click the hamburger button at the top left, and then click Create a resource.
2. In the Search services and marketplace search bar, type network interface and select the Network interface result.
3. Click Create to open the Create network interface form, and enter or select the following values:

        Resource group: select the sandbox resource group starting with pluralsight-

        Name: eastus-web-nic

        Region: East US

        Virtual network: eastus-vnet

        Subnet: web (10.100.0.0/24)

        Private IP address assignment: Static

        Private IP address: 10.100.0.4

        Network security group: eastus-web-nsg
4. Click Review + create to proceed to the validation step, and then click Create.
5. Wait for the deployment to complete, and then click Go to resource.
6. In the Settings section of the left sidebar, click IP configurations, and then click Ipv4config to begin editing the primary IP configuration.
7. In the Public IP address settings section, click Associate, then select eastus-web-ip for the Public IP address, and then click Save, and close the blade by click X.

If you navigate back to the Overview screen for the eastus-web-nic resource, you will see 10.100.0.4 under the Private IP address subheading, and the Azure-generated public IP address for the eastus-web-ip resource under the Public IP address subheading.

# Create a Public Virtual Machine

You have now created and configured all the networking resources required to host a virtual machine in Azure. Next you create a new virtual machine in the East US region of Azure which uses the previously created resources.

1. Click the hamburger button at the top left, and then click Create a resource.
2. In the Popular section, click Windows Server 2019 Datacenter.
3. In the Create a virtual machine form, enter or select the following values:

        Resource group: select the sandbox resource group starting with pluralsight-.

        Virtual machine name: eastus-web

        Region: (US) East US

        Availability options: No infrastructure redundancy required

        Size: Standard_DS1_v2 - 1 vcpu, 3.5 GiB memory

        Username: pluralsight

        Password: P@$$w0rd1234!

        Confirm password: P@$$w0rd1234!

        Public inbound ports: None
4. At the top of the screen, click on the Networking tab, and then select the following values:
        Virtual network: eastus-vnet
        Subnet: web (10.100.0.0/24)
        Public IP: None
        NIC network security group: None

5. Click Review + create to proceed to the validation step, and then click Create.
6. Wait for the deployment to complete, which may take a few minutes, and then click Go to resource.

    The virtual machine has now been created, but is not using the network interface you created in the last challenge. A virtual machine needs to be stopped before network interface(s) can be attached/detached from it.

7. At the top of the screen, click Stop, and then click Yes to confirm.
8. Wait for the virtual machine to stop.

    Note: You will get a notification that says Successfully stopped virtual machine when the virtual machine has stopped.
9. In the Settings section of the left sidebar, click Networking, and then click Attach network interface.
10. Select eastus-web-nic and then click OK.
11. Click Detach network interface, select the network interface which is not named eastus-web-nic (e.g. eastus-web123), and then click OK.
12. Wait for the network interface to detach.

    Note: You will get a notification that says Detached network interface when the network interface has detached. 

13. In the left sidebar, click Overview, and then click Start. 

You now have a virtual machine which is hosted in the East US region of Azure, which uses the static public IP you previously created, and which is only publicly accessible via HTTPS or RDP.

To check this is working, try using RDP to connect to the virtual machine, using its public IP and the username/password detailed in step 3 of this challenge. If you succeed then the virtual machine has been configured correctly.

# Create a Route Table

The East US web-tier is almost complete. Your final challenge is to configure all network packets leaving the East US web-tier and destined for the West US data-tier to be routed via the existing network virtual appliance (NVA) in the West US network, using a route table.

1. Click the hamburger button at the top left, and then click Create a resource.
2. In the Search the Marketplace search bar, type route table and select the Route tables result.
3. Click Create to open the Create Route table form, and enter or select the following values:

        Resource group: select the sandbox resource group starting with pluralsight-.

        Region: East US

        Name: eastus-web-rt
4. Click Review + create to proceed to the validation step, and then click Create.
5. Wait for the deployment to complete, and then click Go to resource.
6. In the Settings section of the left sidebar, click Subnets, and then click Associate.
7. Select the eastus-vnet for the Virtual network, then select web for the Subnet, and then click OK.
8. In the Settings section of the left sidebar, click Routes, and then click Add.
9. In the Add route form, and enter or select the following values:

        Route name: data-via-nva

        Address prefix: 10.0.1.0/24

        Note: This is the address prefix of the West US data-tier.

        Next hop type: Virtual appliance

        Next hop address: 10.0.0.4

        Note: This is the static private ip address of the NVA in the West US network

10. Click OK to create the route.

    To verify the routing is configured correctly, you can RDP into the eastus-web virtual machine and use tracert, a tool which can diagnose each hop taken by a packet across a network.

11. Navigate to the eastus-web virtual machine, click Connect, and select RDP. 
12. Open the downloaded file and use the following credentials to login: 

    Username: pluralsight

    Password: P@$$w0rd1234!

13. Open Windows PowerShell and execute the following command:

    New-NetFirewallRule –DisplayName "Allow ICMPv4-In" –Protocol ICMPv4

    This will allow ICMP through the Windows Firewall, which is not recommended in production scenarios.
14. In the same RDP session, use RDP again to connect to 10.0.1.4 (the IP address of the westus-data virtual machine), using these credentials:

        username: pluralsight

        password: FAax2j>B94%!!!Yg

15. Repeat step 13 in the nested RDP session, and then exit the nested RDP session.
16. Finally, execute the trace route command from within the eastus-web virtual machine RDP session:

    tracert 10.0.1.4

The trace route output should show that the network packets were routed via 10.0.0.4, which is the private IP address of the NVA in the West US network (and the next hop address on the route you configured in this challenge). The output will look something like this: