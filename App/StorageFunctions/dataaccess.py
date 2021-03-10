from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import os



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
    return download_data.content_as_text(max_concurrency=1, encoding='UTF-8')

print(get_user_object("user1.json"))