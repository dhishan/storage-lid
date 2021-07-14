from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
import os, json
from flask import current_app

def blob_service_client():
    try:
        current_app.logger.info("Getting blob service client")
        storage_account_url = os.environ['STORAGE_URI']
        # storage_account_url = "https://datastrdhishan.blob.core.windows.net/"
        token_credential = DefaultAzureCredential()
        return BlobServiceClient(
                account_url=storage_account_url,
                credential=token_credential
            )
    except KeyError as e:
        raise KeyError("STORAGE_URI not found")
    except Exception as ex:
        raise ex
    
def get_blob_data(name,container):
    current_app.logger.critical("Getting Blob Info {0}".format(name))
    try:
        container_client = blob_service_client().get_container_client(container)
        blob_client = container_client.get_blob_client(name)
        download_data = blob_client.download_blob()
        return json.loads(download_data.content_as_text(max_concurrency=1, encoding='UTF-8')),200
    except Exception as e:
        current_app.logger.critical("Error Retrieving blob data {0}".format(e))
        return {"msg":str(e),"code":400},400

def list_all_blobs(container):
    current_app.logger.critical("Getting list of blobs from container:{0}".format(container))
    try:
        container_client = blob_service_client().get_container_client(container)
        blob_list = container_client.list_blobs()
        orgs = [org.name for org in blob_list]
        return orgs,200
    except Exception as e:
        current_app.logger.critical("Error lisiting container {0}".format(e))
        return {"msg":str(e),"code":400},400