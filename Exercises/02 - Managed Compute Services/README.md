# Reference:

[Udemy](https://capgemini.udemy.com/course/azure-certification-az-900-azure-fundamentals/learn/lecture/26525500#overview)

https://learn.microsoft.com/en-us/azure/app-service/provision-resource-terraform
https://learn.microsoft.com/en-us/azure/app-service/deploy-run-package

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

# Build the docker image

1. Log to the ACR registry

```shell
# this line is in the output of the terraform model
docker login --username xxxx --password xxxx acrd30da6.azurecr.io
```

2. Build the image and upload it

```shell
cd msdocs-python-flask-webapp-quickstart
docker build -t webapp-python-docker:latest .
docker tag webapp-python-docker:latest acrd30da6.azurecr.io/webapp-python-docker:latest
docker push acrd30da6.azurecr.io/webapp-python-docker:latest
```

