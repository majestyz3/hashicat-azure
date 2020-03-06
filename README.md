# hashicat
Hashicat: A terraform built application for use in Hashicorp workshops

Includes "Image World" website.

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

## Steps to running the demo

0. Make sure you start with the vm_size: Standard_A1
1. Start with the very top showing organizations, workspaces, modules, and settings.
2. Go to settings and show the Users, Teams (show Ops team), VCS Providers, Authentication, then Policy Sets
3. Talk about the tfe_policy and how you can enable this for all workspaces in the organization or specific ones.
4. Go to the hashicat-azure workspace and talk about variables
5. Show the VS Code repo file of variables.tf, main.tf, outputs.tf
6. Queue and run a plan manually
7. Show the plan step then the cost estimation
8. Show how we have 2 policies: restrict-vm-size and restrict-cost and they both failed.
9. Show how you can override the policy check becuase it is a soft-mandatory and that you have privilege to do so.
10. Make sure to leave comments for audit purposes
11. Apply the plan and leave a comment.
12. Under Plan Finished: show Mocking Sentinel Terraform data - Terraform Cloud provides the ability to generate mock data for any run within a workspace. This data can be used with the Sentinel CLI to test policies before deployment.
13. While the environment is getting built, pull up the tfe_policy repo in VS Code and explain the two sentinel policies and why they failed.
14. Walk through the settings in the workspace section
15. Entire app deploys and show the result URL
16. Fix the vm_size variable to Standard_A0, change the placeholder variable to something else and re-run manually
17. Entire app redeploys and with no policy errors.
18. While app is deploying, show the state files under States
19. Show the result URL
20. Do NOT Destroy the environment if you will use it for the hashicat-azure-modules demo


