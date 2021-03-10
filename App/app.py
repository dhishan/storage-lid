from flask import Flask
from StorageFunctions.dataaccess import *
app = Flask(__name__)

@app.route("/")
def hello():
    # print(type(get_user_object("user1.json")))
    return get_user_object("user1.json")