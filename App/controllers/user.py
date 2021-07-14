from helpers import azstorage
from flask import current_app

def get(name):
    current_app.logger.info(f"Get user blob for {0}",name)
    return azstorage.get_blob_data(name,"users")

def list_all():
    current_app.logger.info("Calling Get all Users")
    return azstorage.list_all_blobs("users")