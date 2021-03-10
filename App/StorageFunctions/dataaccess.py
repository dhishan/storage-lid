from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import os

# os.environ["AZURE_TENANT_ID"] = "94a8b28b-7de6-4eba-af01-5dfd2c03c072"
# os.environ["AZURE_CLIENT_ID"] = "d949f8e0-b680-42b2-a3df-51345bef083a"
# token_credential = InteractiveBrowserCredential()

storage_account_url = "https://datastrdhishan.blob.core.windows.net/"
token_credential = DefaultAzureCredential()
blob_service_client = BlobServiceClient(
    account_url=storage_account_url,
    credential=token_credential
)

def get_user_object(name):
    container_client = blob_service_client.get_container_client("users")
    blob_client = container_client.get_blob_client(name)
    download_data = blob_client.download_blob()
    return content_as_text(max_concurrency=1, encoding='UTF-8')

# print(get_user_object("user1.json"))