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

## Deployment

Using github action you can automatically deploy your function:

* Create the file `.github/workflows/main-lab56d3ee(production).yml`
* Add the following content:

```yaml

# Docs for the Azure Web Apps Deploy action: https://github.com/azure/functions-action
# More GitHub Actions for Azure: https://github.com/Azure/actions
# More info on Python, GitHub Actions, and Azure Functions: https://aka.ms/python-webapps-actions

name: Build and deploy Python project to Azure Function App - lab56d3ee

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  AZURE_FUNCTIONAPP_PACKAGE_PATH: '.' # set this to the path to your web app project, defaults to the repository root
  PYTHON_VERSION: '3.8' # set this to the python version to use (supports 3.6, 3.7, 3.8)

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Setup Python version
        uses: actions/setup-python@v1
        with:
          python-version: ${{ env.PYTHON_VERSION }}

      - name: Create and start virtual environment
        run: |
          python -m venv venv
          source venv/bin/activate

      - name: Install dependencies
        run: pip install -r requirements.txt
        
      # Optional: Add step to run tests here

      - name: Upload artifact for deployment job
        uses: actions/upload-artifact@v2
        with:
          name: python-app
          path: |
            . 
            !venv/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'production'
      url: ${{ steps.deploy-to-function.outputs.webapp-url }}

    steps:
      - name: Download artifact from build job
        uses: actions/download-artifact@v2
        with:
          name: python-app
          path: .

      - name: 'Deploy to Azure Functions'
        uses: Azure/functions-action@v1
        id: deploy-to-function
        with:
          app-name: 'lab56d3ee'
          slot-name: 'production'
          package: ${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}
          publish-profile: ${{ secrets.AzureAppService_PublishProfile_1234 }}
          scm-do-build-during-deployment: true
          enable-oryx-build: true
```