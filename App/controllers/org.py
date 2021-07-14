# from helpers.azstorage import *
from helpers import azstorage
from flask import current_app

def get(name):
    current_app.logger.info(f"Get org blob for {0}",name)
    return azstorage.get_blob_data(name,"org")

def list_all():
    current_app.logger.info("Calling Get all Orgs")
    return azstorage.list_all_blobs("org")