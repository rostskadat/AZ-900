# Reference:

# HOWTO

* Start the lab by using the credentials provided to call the `Start-AzLab` cmdlet

```powershell
Start-AzLab -DeviceCode
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

# Description

This template will setup your account with a default resource group (that can then be used through out the different exercises) and also a budget and cost alert to alert you if you are close to your monthly cost threshold

