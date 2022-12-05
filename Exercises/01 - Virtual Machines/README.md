# Reference:

[Udemy](https://capgemini.udemy.com/course/azure-certification-az-900-azure-fundamentals/learn/lecture/26525562#overview)

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
