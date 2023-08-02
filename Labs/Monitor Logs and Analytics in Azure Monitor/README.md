# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/74d6bc30-a699-447f-bee5-16d18124890b/toc)

https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric-create-templates
https://techcommunity.microsoft.com/t5/azure-database-support-blog/how-to-query-azure-sql-metrics-using-powershell/ba-p/1753305
https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported
https://learn.microsoft.com/en-us/azure/azure-monitor/app/create-workspace-resource
https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net60&pivots=development-environment-psget

# Configure Metrics

You're the administrator of your company's Azure infrastructure. With these systems being critical to your company's operations, you'll set up monitoring and diagnostics to help watch for problems.

1. Once the lab environment is ready, click on the Open Azure portal button to the right of these instructions, then log in to the Azure console using the credentials provided. 

    Note: Ensure you first log out of all other Azure sessions. Using Incognito, for example, will normally accomplish this.

2. On the Azure Portal page, click All resources.

3. Click the check box at the top of the list to select all resources, then click Assign tags.

4. On the Assign tags blade, add a tag with a Name of refresh and a Value of test. Click Save.

        Note: This tag is not an important part of the lab, it's merely created to avoid a common error where resources fail to populate in various drop-down fields in Azure's UI.

5. In the top search bar, type in and click on Monitor.

6. Near the top of the left-hand menu, click on Metrics.

7. At the Select a scope panel, click the checkbox for the scope with the prefix azurequeueslab  (if you don't see it listed, type storage into the Search to filter items... bar then press enter).

8. At the bottom of the panel, click Apply.

9. Back at the Metrics page, from the Metric dropdown, select Success Server Latency .

    Note: The Metric Namespace value of Account is the default, and can remain untouched.

A Success Server Latency line graph will appear, with times (actually dates) as the X axis, and latency in ms as the Y axis. The line graph will likely be flat at this point, although it will as you progress through this lab show more significant changes.

Note: You can use metrics to, for example, ensure there are no issues with monitored resources. The following is beyond the scope of this lab, but you can pin a metric to your Dashboard for later use. Your Dashboard is available through the ☰ menu in the upper-left, and the Dashboard link in the breadcrumbs menu, also in the upper-left of this Metrics page.

# Create a Log Analytics Workspace

1. In the top search bar, type in and click on Log Analytics workspaces.

2. Right under the Log Analytics workspaces title, click on + Create.

3. For Resource group, select pluralsight-resource-group.

4. For Name, enter a name prefixed by monitor-ws.

    Note: The name must be unique. You will get an error message if it conflicts with an existing name, in which case add on further characters until you get a unique name. The monitor-ws name will be used later in the lab when referring to this workspace.

5. For Region, select East US.

6. Click Review + Create, then click Create.

    After the deployment is complete (it may take a few seconds), click on Go to resource.

You will be at a monitor-ws page for the log analytics workspace you just created.

# Configure Diagnostic Settings

1. At the monitor-ws page, in the left-hand menu scroll down to the  Monitoring section, then click Diagnostic settings.

2. Click + Add diagnostic setting.

3. At the Diagnostic setting page, enter the following:

        Diagnostic setting name: AuditToAnalytics

        Logs: Check audit

        Destination details: Check Send to Log Analytics workspace

5. In the top-left, click Save.

    Note: Before clicking Save, the page will look similar to the followingfigure﻿

Upon completion, the Save button will be greyed out, and beside Diagnostic setting name you'll see AuditToAnalytics.

# Configure Log Analytics and Create a Query

1. In the top search bar, type in and click on Monitor.

2. In the left-hand menu, click on Logs.

    If you're greeted with a Welcome to Log Analytics page, dismiss it by clicking the X in its top right-hand corner.

3. At the Select a scope page, type in monitor-ws in the Search to filter items... bar, press enter, and select monitor-ws, then click Apply.

4. At the right of the page under the Run button, in the query editor which says Type your query here, paste in the following:

    LAQueryLogs | where TimeGenerated > ago(1h) | summarize count() by tostring(ResponseCode), bin(TimeGenerated, 1m) | render columnchart with (kind=stacked) 

    This log analytics query will take all response codes logged from the last hour, count the number of each type of response code, and render a bar graph based on that count.

5. Near the top, click on Save > Save as query.  In the Save as query pop-up, fill out the fields as follows, then click Save:

        Query name: LogAnalyticsResponseCodes 

        Check the box for Save as Legacy query

        Legacy category: Query Category

6. Click on the first line of the query you entered earlier to select it, then click Run.

Below the query in the Chart tab you will see a bar graph. If not, wait for about five minutes, then run it again; the query uses data created from this lab, so it is possible that no results will have been logged when you first run the query. When you do have results, you will likely see between one to four bars, and when you hover over a bar you will see ResponseCodes of 200 or 204.

# Set up Alerts

1. In the left-hand menu, click Alerts.

2. Click Create > Alert rule.

3. At the Create an alert rule page, at the Scope tab, click + Select scope.

4. In the Select a resource panel, from Filter by resource type select Storage accounts, then click the row with the Resource prefixed by azurequeueslab. Click Done. 

5. Back at the Create an alert rule page, click the Condition tab. 

    A Select a signal panel will show up. You may need to wait a few seconds for the signals to show up.

6. In the Select a signal panel, click the row with a Signal name of Egress.

7. In the Egress configuration panel, scroll down to the bottom, and at the end of the Alert logic section, leave Threshold as Static, and for Threshold value enter 0.

    Note: Leave all other values as they are.

8. Click the Actions tab, then click + Create action group.

9. At the Create action group page, enter the following

        Resource group: pluralsight-resource-group 

        Action group name: StorageAccountAlerts

        Display name: StrAcntAlts

    Click Review + create, then click Create.

10. Back at the Create an alert rule page, click the Details tab, then enter the following:

        Alert rule name: StorageAcountAnyEgressAlert

        Alert rule description: Alert triggers every minute there is any egress from the storage account.

11. Click Review + create, then click Create.

12. You will be back at the Monitor | Alerts page. Click Alert rules. 

You may need to wait five to 15 minutes for the alert to show up. Click Refresh periodically until it does. When Azure is done, it will show a row with the alert you just created.

You can open a new tab to the Azure portal and continue with the rest of the lab, coming back later to the Alert rules page to see the alert.

# Configure Application Insights

You will create an Application Insights resource which will monitor an application you will create in the next challenge.

1. In the top search bar, type in and click on Application Insights.

2. Click Create Application Insights apps.

3. At the Application Insights page, enter the following:

        Resource Group: pluralsight-resource-group

        Name: monitor-ai

        Region: (US) East US

        Log Analytics Workspace: monitor-ws

        Note: This will be the prefix for the name of the workspace you created earlier in the lab

    Click Review + create, then click Create.

5. Click Go to resource once it's ready.

You will be at the monitor-ai page for the Application Insights resource you just created.


# Create an Application to Monitor

You will now create an ASP.NET Core application, and will configure it so you can monitor it using the Application Insights resource you created in the last challenge.

    Copy the Connection String from the monitor-ai page and save it in a text document for later use.

    Near the top of the screen, click on the Cloud Shell button which is located immediately to the right of the top search bar.

    In the Welcome to Azure Cloud Shell window, click on PowerShell.

    In the You have no storage mounted window, click on Show advanced settings, and enter the following:

        Cloud Shell region:  East US

        Resource group: Select Use existing, and choose pluralsight-resource-group

        Storage Account: Select Use existing, and choose azurequeueslab.

        Note: It should automatically select the storage account prefixed with azurequeueslab. If Use existing cannot be chosen, copy the full name of the Storage account (for example, it will look something like azurequeueslab8716067931. You can open a new browser tab to the portal, and use the top search bar to go to Storage accounts, and copy the full name from there). Then choose Create new, and paste in the Storage account's full name.

        File share: powershell (Leave Create new selected.)

    Click Create storage.

    Once the PowerShell command prompt is available, run the command dotnet new mvc -o mvc --no-https

    Enter cd mvc, then enter dotnet add package Microsoft.ApplicationInsights.AspNetCore

    Note:

        If the prompt becomes muddled, you can reset it at any time by ensuring you're at the command prompt and then pressing Ctrl + L.

        At this point you have a simple ASP.NET Core MVC application created, and the Application Insights package installed.

    Enter code .

    This will open a code editor to the MVC project. You'll likely want to resize the window to make it easier to work with.

    In the editor, on the left under FILES, click on appsettings.json.

    Overwrite the contents of appsettings.json with the JSON below, then replace <Connection String> on line 11 with the value you stored earlier (make sure to enter the connection string within double quotes).

    {

      "Logging": {

        "LogLevel": {

          "Default": "Information",

          "Microsoft": "Warning",

          "Microsoft.Hosting.Lifetime": "Information"

        }

      },

      "AllowedHosts": "*",

      "ApplicationInsights": {

        "ConnectionString" : "<Connection String>"

      }

    } 

    Note:

        You are adding the ApplicationInsights setting, which will allow Application Insights to monitor this application.

    Save the file using either the keyboard shortcut (cmd/ctrl + s) or by clicking the ... button at the top right corner of the editor and choosing Save. 

    Click on FILES > Program.cs.

    Right after the builder.Services.AddControllersWithViews() on line 4, add the following code:

    builder.Services.AddApplicationInsightsTelemetry();

    Save Program.cs

    Click on FILES > Controllers > HomeController.cs.

    Overwrite the existing Index() method on line 16 with the following code:

    public IActionResult Index()

            {

                _logger.LogWarning("Index accessed successfully");

                return View();

            }

    Note:  You are adding the call to LogWarning().

    Save HomeController.cs.

    Back at the command prompt, run the command dotnet run

    At the top of the PowerShell panel, click the Web preview button (shown below), then click on Configure. figure﻿

    In the Configure port to preview window, type in the port for your running dotnet application. You can find this in the command line output at the bottom of the page, on the line that says  Now listening on: http://localhost:<port>. Click Open and browse. This will open a new browser tab (or window) to a Welcome web page.

    Note: If you see a message that you're not authenticated, click the Sign in link, wait a moment for a new window to load and authenticate you, then close the new window and refresh the page.

    At the Welcome web page, click your browser's refresh button several times, then close the new tab. This will generate log events which you will monitor via Application Insights.

    Back in the portal browser tab, in the upper-right of the PowerShell panel, click the X to close the panel.

    In the left-hand menu click on Transaction search.

    Click See all data in the last 24 hours.

You will see under Results various events, including the log warning your code printed, Index accessed successfully. There may be a bit of a delay, so if you don't yet see any events, click the Refresh button after a few minutes.

Now everything is set up for your developers to be able produce a proper web application with application insights enabled.

