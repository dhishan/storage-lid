from helpers import azstorage


def get(name):
    return azstorage.get_blob_data(name,"users")

def list_all():
    return azstorage.list_all_blobs("users")