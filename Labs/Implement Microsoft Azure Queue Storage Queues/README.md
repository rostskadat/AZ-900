# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/bedf1a3c-039e-4b9f-b88d-2c828adeee6c/toc)

https://learn.microsoft.com/en-us/azure/storage/queues/storage-powershell-how-to-use-queues
https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-csharp?tabs=azure-powershell%2Cin-process
https://learn.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell
https://github.com/javiramos1/azure_functions_terraform_demo

# HOWTO

* Start the lab by using the credentials provided to call the `Start-AzLab` cmdlet

```powershell
Start-AzLab "<lab_email>" "<lab_password>"
```

* This must have set the `ARM_*` environment variables

```powershell
Get-ChildItem env:ARM_*
```

* You can then use the traditional `terraform` commands

```powershell
terraform init 
...
terraform plan -out tf.plan
...
terraform apply tf.plan
```

* You can then test your function locally:

```powershell
cd src
func.exe start
```

* And then deploy it to Azure

```powershell
cd src
func azure functionapp publish IncomingRequestHandler
...
curl http://localhost:7071/api/IncomingRequestHandler

StatusCode        : 200
StatusDescription : OK
Content           : This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.
R
```

__Do not forget to remove all your resources at the end of the lab__

```powershell
terraform destroy -auto-approve
```
