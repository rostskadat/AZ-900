# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/4f82b61a-3c8c-48dc-b3db-496e45c3fc21/toc)

https://learn.microsoft.com/en-us/azure/cosmos-db/scripts/powershell/nosql/create
https://learn.microsoft.com/en-us/rest/api/cosmos-db/execute-a-stored-procedure
https://learn.microsoft.com/en-us/rest/api/cosmos-db/common-cosmosdb-rest-request-headers

# Access the Azure Cosmos DB Data Explorer

GloboTicket has recently taken its operations global by deploying its ticketing platform to Azure and the corresponding data to Azure Cosmos DB. As a JavaScript developer, you have joined their team, focusing on improving the current applications.

As you began evaluating their existing software stack, you realized that many of their applications perform complex transactional operations client-side. As a developer, you feel that you could improve the ticketing platform's manageability and performance by moving many of these operations to server-side code running within Azure Cosmos DB.

Before writing your first server-side programming entities, you will become familiar with the in-portal environment you will eventually use to run queries and code within Azure Cosmos DB.

1. Click the Open Azure console button located to the right of this text, then use the cloud sandbox credentials to log in.
2. Navigate to Resource Groups, and choose the Cosmos resource group that was created on your behalf in the sandbox subscription.
3. Within the resource group, select the Azure Cosmos DB account that begins with a prefix of cosmos-.

    ❗ Note: This Azure Cosmos DB account was automatically created for you within the sandbox subscription. It will have a prefix of cosmos- and a suffix of random alphanumeric characters.

4. On the Azure Cosmos DB account blade, select Data Explorer from the navigation menu.

    ❗ Note: It can sometimes take up to fifteen minutes for a new Azure Cosmos DB account to be ready for use. If the navigation menu options are disabled, this is likely because the account is still in the Creating state.

5. Within the Data Explorer, expand the pre-existing Retail database and Customers container nodes.
6. Within the Customers container node, select the Scale & Settings option.

Once you select Scale & Settings, you have a new tab open that shows the default settings pre-configured for the Customers container. Leave the Data Explorer open, you will use this tool in the remaining challenges throughout this lab.


# Execute a Stored Procedure

It’s time to test your new stored procedure. You can use the Data Explorer to view, update, or execute a stored procedure.

1. In the navigation menu, select Execute and an Input parameters panel will appear.
2. In the Key dropdown for the partition key value, select String then set the Value to  records.
3. In the Edit input parameters section, select String for the Key and enter the Value as  First Record.
4. Select + Add New Param to add a Custom parameter with a value of 347568.
5. Select Execute. After execution, you'll see a new document appear in the Result pane.figure﻿
6. In the navigation menu, select Execute to open the Input parameters pop-up dialog again.
7. Set the Partition key value to records again, then in the first input parameters box, create a String with a value of Second Record.
8. Add a new Custom param with a value of 123709.
9. Select Execute. After execution, you'll see a new document in the Result pane.

You can confirm that both documents were created successfully by navigating within Data Explorer to Retail > Customers > Items, where you should see both documents you created. You have executed your stored procedure twice, creating two separate documents in your Azure Cosmos DB container. You will query these documents in the remaining challenges of  this lab.