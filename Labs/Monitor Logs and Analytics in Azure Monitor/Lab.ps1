# Start-AzLab
$REGION_ID = 'eastus'
$RESOURCE_GROUP_NAME = 'pluralsight-resource-group'

#------------------------------------------------------------------------------
#
# Configure Metrics
#
# tag all resources to populate the different resources
foreach ($resource in Get-AzResource -ResourceGroupName $RESOURCE_GROUP_NAME) {
    New-AzTag -ResourceId $resource.ResourceId -Tag @{'test' = 'refresh' }
}

# obtain the metric
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCE_GROUP_NAME | Where-Object { $_.StorageAccountName -match 'azurequeueslab' } | Select-Object -First 1

# REF https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported
$MonitorParameters = @{
    ResourceId      = $StorageAccount.Id
    TimeGrain       = [TimeSpan]::Parse('00:05:00')
    MetricNames     = @('SuccessServerLatency', 'Availability')
    StartTime       = (Get-Date).AddDays(-1)
    AggregationType = 'Average'
}
$Metrics = Get-AzMetric @MonitorParameters

foreach ($Metric in $Metrics) {
    $Resuts += $Metric.Data | Select-Object TimeStamp, Average, @{Name = 'Metric'; Expression = { $Metric.Name.Value } }
}

$Resuts | Sort-Object -Property TimeStamp, Metric | Format-Table

# Create a Log Analytics Workspace
$WorkspaceName = "monitor-ws-$(Get-Random)"
New-AzOperationalInsightsWorkspace -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name $WorkspaceName -Sku PerGB2018 

$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $RESOURCE_GROUP_NAME -Name $WorkspaceName

Get-AzMetricDefinition -ResourceId $Workspace.ResourceId

#------------------------------------------------------------------------------
#
# Configure Diagnostic Settings
#
Set-AzDiagnosticSetting -Name AuditToAnalytics -WorkspaceId $Workspace.ResourceId -EnableLog $true -Category Audit -ResourceId $Workspace.ResourceId

#------------------------------------------------------------------------------
#
# Configure Log Analytics and Create a Query
#
$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query 'LAQueryLogs | where TimeGenerated > ago(1h) | summarize count() by tostring(ResponseCode), bin(TimeGenerated, 1m) | render columnchart with (kind=stacked)'
$Results.Results | Format-Table

#------------------------------------------------------------------------------
#
# Set up Alerts
#

$Email = New-AzActionGroupReceiver -Name 'Alert' -EmailReceiver -EmailAddress (Get-AzAccessToken).UserId
Set-AzActionGroup -ResourceGroup $RESOURCE_GROUP_NAME -Name 'StorageAccountAlerts' -ShortName 'StrAcntAlts' -Receiver $Email

$ag = Get-AzActionGroup -ResourceGroupName $RESOURCE_GROUP_NAME -Name 'StorageAccountAlerts'
$ActionGroup = New-AzActionGroup -ActionGroupId $ag.Id

#$dim = New-AzMetricAlertRuleV2DimensionSelection -DimensionName "Computer" -ValuesToInclude "*"

#-DimensionSelection $dim
$Criteria = New-AzMetricAlertRuleV2Criteria -MetricName 'Egress' -TimeAggregation Total -Operator GreaterThan -Threshold 0

Add-AzMetricAlertRuleV2 -ResourceGroupName $RESOURCE_GROUP_NAME `
    -Name 'StorageAcountAnyEgressAlert' `
    -Description 'Alert triggers every minute there is any egress from the storage account.' `
    -TargetResourceId $StorageAccount.Id `
    -WindowSize 00:05:00 `
    -Frequency 00:01:00 `
    -Criteria $Criteria `
    -ActionGroup $ActionGroup `
    -Severity 3


#------------------------------------------------------------------------------
#
# Configure Application Insights    
#
New-AzApplicationInsights -ResourceGroupName $RESOURCE_GROUP_NAME -Location $REGION_ID -Name monitor-ai -WorkspaceResourceId $Workspace.ResourceId

# InstrumentationKey=787acb5d-f591-478c-a390-84cb3645d578;
# IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;
# LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/

#------------------------------------------------------------------------------
#
# Create an Application to Monitor
#
$WebAppName = 'LabLogAnalytics'
dotnet new mvc -o $WebAppName --no-https
Set-Location $WebAppName
# if it fails check that your $Env:APPDATA\NuGet\NuGet.config has the following config
#   <packageSources>
#     <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
#   </packageSources>
dotnet add package Microsoft.ApplicationInsights.AspNetCore

(Get-Content 'appsettings.Development.json') -replace '<ConnectionString>', 'AppInsight.ConnectcionString.from.Portal' | Set-Content 'appsettings.Development.json'


$WebApp = Get-AzWebApp -ResourceGroupName $RESOURCE_GROUP_NAME -Name $WebAppName -ErrorAction Stop
$newAppSettings = @{} # case-insensitive hash map
$WebApp.SiteConfig.AppSettings | ForEach-Object { $newAppSettings[$_.Name] = $_.Value } # preserve non Application Insights application settings.
$newAppSettings['APPINSIGHTS_INSTRUMENTATIONKEY'] = '012345678-abcd-ef01-2345-6789abcd'; # set the Application Insights instrumentation key
$newAppSettings['APPLICATIONINSIGHTS_CONNECTION_STRING'] = 'InstrumentationKey=012345678-abcd-ef01-2345-6789abcd'; # set the Application Insights connection string
$newAppSettings['ApplicationInsightsAgent_EXTENSION_VERSION'] = '~2'; # enable the ApplicationInsightsAgent
$WebApp = Set-AzWebApp -AppSettings $newAppSettings -ResourceGroupName $WebApp.ResourceGroup -Name $WebApp.Name -ErrorAction Stop