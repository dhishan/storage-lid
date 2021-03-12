from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import os, json

def blob_service_client():
    # storage_account_url = os.environ['STORAGE_URI']
    storage_account_url = "https://datastrdhishan.blob.core.windows.net/"
    token_credential = DefaultAzureCredential()
    return BlobServiceClient(
                account_url=storage_account_url,
                credential=token_credential
            )

def get_blob_data(name,container):
    container_client = blob_service_client().get_container_client(container)
    blob_client = container_client.get_blob_client(name)
    download_data = blob_client.download_blob()
    return json.loads(download_data.content_as_text(max_concurrency=1, encoding='UTF-8'))

def list_all_blobs(container):
    container_client = blob_service_client().get_container_client(container)
    blob_list = container_client.list_blobs()
    orgs = [org.name for org in blob_list]
    return orgs