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

# Deploying Webapp manually

1. Create a webapp in the portal
1. az login
1. Create a deployment url
```bash
az webapp deployment source config-local-git --name storageaccessdhishan --resource-group webapp-storage-ui-rg
```
1. Upload the local folder to webapp
```bash

```
This is a minimal Flask app that can be deployed to Azure App Service on Linux.

For instructions on running and deploying the code, see [Quickstart: Create a Python app in Azure App Service on Linux](https://docs.microsoft.com/azure/app-service/quickstart-python).

## Rotating Credentials for SPN automatically using terraform

## Contributing

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
