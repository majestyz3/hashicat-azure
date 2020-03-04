# hashicat
Hashicat: A terraform built application for use in Hashicorp workshops

Includes "Meow World" website.

[![CircleCI](https://circleci.com/gh/hashicorp/hashicat-azure/tree/master.svg?style=svg)](https://circleci.com/gh/hashicorp/hashicat-azure/tree/master)

## Install azure-cli

homebrew didn't work for me as there were issues installing python3.8. I ended up using:

```shell
pip3 install azure-cli
```

Then run:

```shell
az configure
az login
```

## Instructions to create a principle service name to be used with TF

Use these instructions:
Generic to TF Azure Provider:
https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html

Specific to us as SEs:
https://hashicorp.atlassian.net/wiki/spaces/SE/pages/310509843/Microsoft+Azure

I used the az cli to generate everything. You can also use the UI.
```shell
az account list
```

```json
{
    "cloudName": "AzureCloud",
    "homeTenantId": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
    "id": "14692f20-9428-451b-8298-102ed4e39c2a",
    "isDefault": false,
    "managedByTenants": [
      {
        "tenantId": "2f4a9838-26b7-47ee-be60-ccc1fdec5953"
      }
    ],
    "name": "Team Solutions Engineers",
    "state": "Enabled",
    "tenantId": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
    "user": {
      "name": "sam.gabrail@hashicorp.com",
      "type": "user"
    }
 ```
NOTE: This should be the "Team Solutions Engineers" subscriptionId
```shell
export SUBSCRIPTION_ID=14692f20-9428-451b-8298-102ed4e39c2a
az account set --subscription="${SUBSCRIPTION_ID}"
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```
As shown in the example below, in the create-for-rbac command, please
use a --name parameter to associate it with your name.
Note: --name does not accept spaces
```shell
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}" --name="samg-Azure-creds"
```
My output:
```json
{
  "appId": "381b292c-8667-473e-92df-9639b7121ecc",
  "displayName": "samg-Azure-creds",
  "name": "http://samg-Azure-creds",
  "password": "xxxxxx",
  "tenant": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec"
}
```
These values map to the Terraform variables like so:

- appId is the client_id defined above.
- password is the client_secret defined above.
- tenant is the tenant_id defined above.
 
Finally, it's possible to test these values work as expected by first logging in:


```shell 
az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID
az login --service-principal -u "381b292c-8667-473e-92df-9639b7121ecc" -p "xxxxxx" --tenant "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec"
```

```json
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
    "id": "14692f20-9428-451b-8298-102ed4e39c2a",
    "isDefault": true,
    "managedByTenants": [
      {
        "tenantId": "2f4a9838-26b7-47ee-be60-ccc1fdec5953"
      }
    ],
    "name": "Team Solutions Engineers",
    "state": "Enabled",
    "tenantId": "0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec",
    "user": {
      "name": "381b292c-8667-473e-92df-9639b7121ecc",
      "type": "servicePrincipal"
    }
  }
]
```

Once logged in as the Service Principal - we should be able to list the VM sizes by specifying an Azure region, for example here we use the West US region:

```shell 
az vm list-sizes --location westus
```

You can create a script that will setup your Azure credentials
when you want to prepare a working environment or demo
DON'T FORGET TO REPLACE THE VALUES WITH YOUR OWN
```shell
$ echo "Setting environment variables for Terraform”
$ export ARM_SUBSCRIPTION_ID=14692f20-9428-451b-8298-102ed4e39c2a
$ export ARM_CLIENT_ID=<your_appId>
$ export ARM_CLIENT_SECRET=<your_password>
$ export ARM_TENANT_ID=<your_tenant_id>
```

Finally, since we're logged into the Azure CLI as a Service Principal we recommend logging out of the Azure CLI (but you can instead log in using your user account):

```shell
az logout
```

There is also some useful instructions here:
https://github.com/hashicorp/terraform-guides/tree/master/infrastructure-as-code/azure-vm