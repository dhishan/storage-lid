# from helpers.azstorage import *
from helpers import azstorage


def get(name):
    return azstorage.get_blob_data(name,"org")

def list_all():
    return azstorage.list_all_blobs("org")