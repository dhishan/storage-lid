---
page_type: sample
description: "A minimal app that can be used to demonstrate accessing storage blobs using webapp"
languages:
- python
- terraform
products:
- azure
- azure-app-service
---

# storage-lid

An end to end automation to demonstrate access of storage account through a REST based web app with native Azure AD integration. 

## Azure Devops Setup

1. A service principal with permissions to create 
    1. Azure AD Application ( old windows azure api applications.write.ownedby permissions )
    2. Owner at the subscription Level


# Insights
## Rotating Credentials for SPN automatically using terraform
TBD
## SPN permissions for app creation using using terraform
TBD
## Python APP using terraform and msft hosted build agents
TBD

## Whitelisting Storage account for build and updating ip address
TBD

## References:
1. Adding an IP to whitelist for build time in Azure Devops
```bash
curl -s http://ipinfo.io/json | jq '.ip'
# https://stackoverflow.com/questions/53422395/how-to-get-the-ip-address-for-azure-devops-hosted-agents-to-add-to-the-white-lis
```

2. For instructions on running and deploying the code, see [Quickstart: Create a Python app in Azure App Service on Linux](https://docs.microsoft.com/azure/app-service/quickstart-python).

